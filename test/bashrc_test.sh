#!/bin/bash

# Test that shell/bashrc runs no program from the current directory.
# Each fake program in the project bin writes a marker file. A marker
# file means that the shell ran repo code.
#
# A $(...) in single quotes is text that the test gives to bash.
# shellcheck disable=SC2016
set -euo pipefail

# A relative PATH entry from an older shell would run the fixture's
# own git in place of the real one.
PATH=$(printf '%s' "$PATH" | tr ':' '\n' | grep '^/' | paste -sd: -)

root=$(cd "$(dirname "$0")/.." && pwd -P)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
tmp=$(cd "$tmp" && pwd -P)

# The login shell is Homebrew bash 5. The CI runner's /bin/bash is
# bash 5 too. The prompt test needs ${PS1@P}, from bash 4.4.
bash=bash
if [ -x /opt/homebrew/bin/bash ]; then
  bash=/opt/homebrew/bin/bash
fi

project="$tmp/project"
markers="$tmp/markers"
stub="$tmp/stub"
mkdir -p "$project/bin" "$markers" "$stub" "$tmp/home"
git -C "$project" init -q
for name in git git-current-branch soc; do
  printf '#!/bin/sh\ntouch %q\n' "$markers/$name" >"$project/bin/$name"
  chmod +x "$project/bin/$name"
done

# A branch named $(marker). The program marker is on PATH, so the
# prompt runs it if bash expands the branch name.
printf '#!/bin/sh\ntouch %q\n' "$markers/branch" >"$stub/marker"
chmod +x "$stub/marker"
git -C "$project" checkout -q -b '$(marker)'
# git rev-parse prints HEAD for a branch with no commit.
GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com \
  GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com \
  git -C "$project" commit -q --allow-empty -m init

failures=0
fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

# Start an interactive shell in the project, as a user does after a
# clone or a checkout. The inherited PATH also has a relative entry and
# an empty entry, as an older shell or a terminal app can pass on. The
# shell has no terminal, so it can write job control warnings to
# stderr.
out=$(cd "$project" && HOME="$tmp/home" PATH="./inherited::$stub:$root/bin:$PATH" \
  "$bash" --norc --noprofile -i -c '
    source "$1"
    printf "%s\n" "$PATH"
    prompt=${PS1@P}
    printf "%s\n" "$prompt"
  ' _ "$root/shell/bashrc" 2>"$tmp/err") || fail "bashrc: $(cat "$tmp/err")"
path=$(printf '%s\n' "$out" | sed -n 1p)
prompt=$(printf '%s\n' "$out" | sed -n 2p)

# Behavior: the exported PATH has only absolute directories.
relative=$(printf '%s' "$path" | tr ':' '\n' | grep -v '^/' || true)
[ -z "$relative" ] || fail "PATH has a relative entry: $relative"
case ":$path:" in *::*) fail "PATH has an empty entry" ;; esac

# Behavior: drawing the prompt runs no project git or git-current-branch.
[ ! -e "$markers/git" ] || fail "the prompt ran ./bin/git"
[ ! -e "$markers/git-current-branch" ] || fail "the prompt ran ./bin/git-current-branch"

# Behavior: the prompt shows the branch name as text, and does not
# run it.
[ ! -e "$markers/branch" ] || fail "the prompt ran the branch name"
case $prompt in
  *'$(marker)'*) ;;
  *) fail "the prompt does not show the branch: $prompt" ;;
esac

# Behavior: shell start-up runs no project soc.
[ ! -e "$markers/soc" ] || fail "start-up ran ./bin/soc"

[ "$failures" -eq 0 ] || exit 1
echo "ok bashrc_test"
