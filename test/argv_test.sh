#!/bin/bash

# Test that repo text reaches a process as separate arguments, not as
# a shell string or an option. This script tests bin/replace, then
# runs test/argv_test.lua in a headless Neovim that loads the
# vim/init.lua of this checkout.
#
# Each hostile name has a $(...) or an rg option that writes a marker
# file. A marker file means that a shell or rg ran repo text as code.
# A file name cannot hold a /, so a $(...) in a name writes its marker
# to the current directory. The test uses a temporary HOME.
set -euo pipefail

# A relative PATH entry from an older shell would run a fixture's own
# programs in place of the real ones.
PATH=$(printf '%s' "$PATH" | tr ':' '\n' | grep '^/' | paste -sd: -)

root=$(cd "$(dirname "$0")/.." && pwd -P)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
tmp=$(cd "$tmp" && pwd -P)

export MARKERS="$tmp/markers"
mkdir -p "$MARKERS"
failures=0

fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

# Behavior: bin/replace reads each file name as a path, not as an rg
# or sed option. A file named --pre=sh makes rg run each file in sh.
dir="$tmp/replace"
mkdir -p "$dir"
printf 'touch "%s/replace"\n' "$MARKERS" >"$dir/x"
printf 'zq1\n' >"$dir/--pre=sh"
printf 'zq1\n' >"$dir/f.txt"
# The bare glob is the attack: it gives each file name as an argument.
# shellcheck disable=SC2035
(cd "$dir" && "$root/bin/replace" zq1 zq2 *) >/dev/null 2>&1 || true
if [ -e "$MARKERS/replace" ]; then
  fail "bin/replace ran a file name as an rg option"
fi
if [ "$(cat "$dir/--pre=sh")" != zq2 ] || [ "$(cat "$dir/f.txt")" != zq2 ]; then
  fail "bin/replace did not edit each file, also the one named --pre=sh"
fi

# Boundary: a find string that starts with - stays a pattern.
printf -- '-zq3\n' >"$dir/g.txt"
(cd "$dir" && "$root/bin/replace" -zq3 zq4 g.txt) >/dev/null 2>&1 || true
if [ "$(cat "$dir/g.txt")" != zq4 ]; then
  fail "bin/replace read the find string -zq3 as an option"
fi

# Behavior: bin/replace changes only the literal find string, as rg -F
# finds it. sed must not read ".", "*", "[", "^", or "$" in the find
# string as syntax, or "\" and "&" in the new text.
printf '%s\n' 'a.c abc a*c [x] ^h$' >"$dir/lit.txt"
for pair in 'a.c|n\1&' 'a*c|w' '[x]|y' '^h$|z'; do
  (cd "$dir" && "$root/bin/replace" "${pair%%|*}" "${pair#*|}" lit.txt) >/dev/null 2>&1 || true
done
if [ "$(cat "$dir/lit.txt")" != 'n\1& abc w y z' ]; then
  fail "bin/replace changed text that is not the literal find string: $(cat "$dir/lit.txt")"
fi

# Keep the real plugins and plugin caches, so that Neovim needs no
# network.
real=$HOME
export XDG_CONFIG_HOME="$real/.config" XDG_DATA_HOME="$real/.local/share"
export XDG_CACHE_HOME="$real/.cache" XDG_STATE_HOME="$tmp/state"
export HOME="$tmp/home" GIT_CONFIG_NOSYSTEM=1

# Stub psql and go write each argument on its own line, so the test
# sees how Neovim split the command. The go stub runs the real go for
# each subcommand other than run. test/argv_test.lua starts no gopls,
# so no process outlives Neovim and writes to HOME while the trap
# removes it.
stubs="$tmp/stubs"
mkdir -p "$stubs"
printf '#!/bin/sh\nprintf "%%s\\n" "$@" >"%s/psql.args"\n' "$MARKERS" >"$stubs/psql"
# shellcheck disable=SC2016 # The stub expands $1 and $@, not this script.
printf '#!/bin/sh\n[ "$1" = run ] || exec "%s" "$@"\nprintf "%%s\\n" "$@" >"%s/go.args"\n' \
  "$(command -v go)" "$MARKERS" >"$stubs/go"
chmod +x "$stubs/psql" "$stubs/go"

export REPO="$tmp/repo"
mkdir -p "$REPO"
git -C "$REPO" init -q
printf 'needle needles\n' >"$REPO/plain.txt"
# shellcheck disable=SC2016 # The token holds a literal $(...).
printf '%s\n' 'a"$(:>kmark)"b' >"$REPO/token.txt"
printf 'select 1;\n' >"$REPO/q\$(:>sqlmark).sql"
printf 'package main\n' >"$REPO/m\$(:>gomark).go"

cd "$REPO"
if ! PATH="$stubs:$PATH" nvim --headless -u "$root/vim/init.lua" \
  -c "luafile $root/test/argv_test.lua"; then
  failures=$((failures + 1))
fi

if [ "$failures" -gt 0 ]; then
  exit 1
fi
echo "ok argv_test"
