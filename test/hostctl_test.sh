#!/bin/bash

# Test bin/hostctl with stub curl and stub sudo.
#
# The stub sudo writes to a file in a temporary directory in place of
# /etc/hosts, and it refuses each command that bin/hostctl must not
# run. So the tests do not change /etc/hosts and do not run the real
# sudo. The stub curl does not use the network.
set -euo pipefail

# A relative PATH entry from an older shell would run a program from
# the current directory in place of the stubs.
PATH=$(printf '%s' "$PATH" | tr ':' '\n' | grep '^/' | paste -sd: -)

root=$(cd "$(dirname "$0")/.." && pwd -P)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
tmp=$(cd "$tmp" && pwd -P)

hostctl="$root/bin/hostctl"
url=https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
export HOME="$tmp/home"
export HOSTS="$tmp/hosts" SUDO_LOG="$tmp/sudo.log" CURL_LOG="$tmp/curl.log"
export FIXTURE="$tmp/download.txt" CURL_MODE=ok
mkdir -p "$HOME" "$tmp/stub"
PATH="$tmp/stub:$PATH"

failures=0
fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

cat >"$tmp/stub/sudo" <<'SH'
#!/bin/bash
echo "$*" >>"$SUDO_LOG"
case "$1" in
tee)
  shift
  args=()
  for a in "$@"; do
    if [ "$a" = /etc/hosts ]; then
      a=$HOSTS
    fi
    args+=("$a")
  done
  exec tee "${args[@]}"
  ;;
killall)
  exit 0
  ;;
*)
  echo "stub sudo: refuse $*" >&2
  exit 1
  ;;
esac
SH

# The stub curl writes the fixture, or an error page and exit code 22
# when CURL_MODE is "fail". A real curl can also write part of the
# body before it fails.
cat >"$tmp/stub/curl" <<'SH'
#!/bin/bash
out=
url=
while [ $# -gt 0 ]; do
  case "$1" in
  -o)
    out=$2
    shift
    ;;
  -*) ;;
  *) url=$1 ;;
  esac
  shift
done
echo "$url" >>"$CURL_LOG"
if [ -n "$out" ]; then
  exec >"$out"
fi
if [ "$CURL_MODE" = fail ]; then
  echo '<html>503 Service Unavailable</html>'
  exit 22
fi
cat "$FIXTURE"
SH
chmod +x "$tmp/stub/sudo" "$tmp/stub/curl"

# The fixture has the line forms of the real list, a CR at each line
# end, and lines that the filter must drop. A "$(" line must stay as
# text.
# shellcheck disable=SC2016
printf '%s\r\n' \
  '# This MVPS HOSTS file is a free download' \
  '127.0.0.1 localhost' \
  '::1 localhost #[IPv6]' \
  '0.0.0.0 localhost' \
  '0.0.0.0 broadcasthost' \
  '0.0.0.0 blog.localhost' \
  '0.0.0.0 LOCALHOST' \
  '1.2.3.4 github.com' \
  '127.0.0.1 evil.example' \
  '0.0.0.0 two.example three.example' \
  '0.0.0.0 -bad.example' \
  '0.0.0.0 bad-.example' \
  '0.0.0.0 under_score.example' \
  '0.0.0.0 dot.example.' \
  '0.0.0.0 a..example' \
  "0.0.0.0 $(printf 'a%.0s' {1..64}).example" \
  '0.0.0.0 $(touch marker).example' \
  '0.0.0.00 zero.example' \
  ' 0.0.0.0 indent.example' \
  '0.0.0.0 ads.example' \
  '0.0.0.0 Tracker.Example #[WebBug]' \
  "0.0.0.0	tab.example" \
  "0.0.0.0 $(printf 'b%.0s' {1..63}).example" \
  >"$FIXTURE"

want_filtered="0.0.0.0 ads.example
0.0.0.0 tracker.example
0.0.0.0 tab.example
0.0.0.0 $(printf 'b%.0s' {1..63}).example"

reset() {
  printf '127.0.0.1 localhost\n# old\n' >"$HOSTS"
  : >"$SUDO_LOG"
  : >"$CURL_LOG"
  CURL_MODE=ok
}

# hostctl_filter keeps only "0.0.0.0 <name>" lines with a valid host
# name. It drops comments, other addresses, and the local names.
reset
if out=$(cd "$tmp" && bash -c 'source "$1" && hostctl_filter "$2"' _ "$hostctl" "$FIXTURE" 2>"$tmp/err"); then
  if [ "$out" != "$want_filtered" ]; then
    fail "hostctl_filter output:
$out"
  fi
else
  fail "hostctl_filter: $(cat "$tmp/err")"
fi
if [ -e "$tmp/marker" ]; then
  fail "hostctl_filter ran a command from the list"
fi

# Sourcing bin/hostctl defines the functions and writes nothing.
reset
(cd "$tmp" && bash -c 'source "$1"' _ "$hostctl") >/dev/null 2>&1 || true
if [ -s "$SUDO_LOG" ] || [ -s "$CURL_LOG" ]; then
  fail "source bin/hostctl ran: $(cat "$CURL_LOG" "$SUDO_LOG")"
fi

# hostctl writes /etc/hosts once. The script's own localhost lines
# come first, and the download adds only filtered lines.
reset
if ! "$hostctl" >/dev/null 2>"$tmp/err"; then
  fail "hostctl: $(cat "$tmp/err")"
fi
if [ "$(cat "$CURL_LOG")" != "$url" ]; then
  fail "hostctl downloaded: $(cat "$CURL_LOG")"
fi
if [ "$(grep -c '/etc/hosts' "$SUDO_LOG")" != 1 ] ||
  grep -q -- '-a' "$SUDO_LOG"; then
  fail "hostctl wrote /etc/hosts more than once: $(cat "$SUDO_LOG")"
fi
if [ "$(grep -v '^#' "$HOSTS" | grep -v '^$' | head -2)" != "127.0.0.1 localhost
::1 localhost" ]; then
  fail "hostctl: /etc/hosts does not start with the localhost lines"
fi
if [ "$(grep -c 'localhost$' "$HOSTS")" != 2 ]; then
  fail "hostctl: /etc/hosts has a localhost line from the download"
fi
if [ "$(grep '^0\.0\.0\.0 ' "$HOSTS")" != "$want_filtered" ]; then
  fail "hostctl: /etc/hosts has unfiltered lines"
fi
if grep -q -e 'github\.com' -e evil -e $'\r' "$HOSTS"; then
  fail "hostctl: /etc/hosts has a line from the download that maps a name"
fi
if ! grep -q '^127.0.0.1 blog.localhost' "$HOSTS"; then
  fail "hostctl: /etc/hosts has no local app entries"
fi

# If the download fails, hostctl stops and /etc/hosts does not change.
reset
before=$(cat "$HOSTS")
CURL_MODE=fail
if "$hostctl" >/dev/null 2>&1; then
  fail "hostctl: exit 0 after a failed download"
fi
if [ "$(cat "$HOSTS")" != "$before" ]; then
  fail "hostctl: /etc/hosts changed after a failed download"
fi
if grep -q '/etc/hosts' "$SUDO_LOG"; then
  fail "hostctl: wrote /etc/hosts after a failed download"
fi

# If the filter keeps no line, such as for an error page served with
# HTTP 200, hostctl stops and /etc/hosts does not change.
reset
before=$(cat "$HOSTS")
empty="$tmp/empty.txt"
printf '<html>Moved</html>\n# no hosts here\n' >"$empty"
if FIXTURE=$empty "$hostctl" >/dev/null 2>&1; then
  fail "hostctl: exit 0 when the filter keeps no line"
fi
if [ "$(cat "$HOSTS")" != "$before" ]; then
  fail "hostctl: /etc/hosts changed when the filter kept no line"
fi

# hostctl --unblock writes the localhost lines and the local app
# entries, and downloads nothing.
reset
if ! "$hostctl" --unblock >/dev/null 2>"$tmp/err"; then
  fail "hostctl --unblock: $(cat "$tmp/err")"
fi
if [ -s "$CURL_LOG" ] || grep -q '^0\.0\.0\.0' "$HOSTS" ||
  ! grep -q '^::1 localhost' "$HOSTS" ||
  ! grep -q '^127.0.0.1 blog.localhost' "$HOSTS"; then
  fail "hostctl --unblock: $(cat "$HOSTS")"
fi

if [ "$failures" -gt 0 ]; then
  echo "$failures failures" >&2
  exit 1
fi
echo "ok hostctl"
