#!/bin/bash

# Test the commands in laptop.sh that make ~/.ssh.
#
# The test does not run laptop.sh, because laptop.sh installs software.
# It runs the ~/.ssh lines from laptop.sh with a temporary HOME.
set -euo pipefail

PATH=$(printf '%s' "$PATH" | tr ':' '\n' | grep '^/' | paste -sd: -)

root=$(cd "$(dirname "$0")/.." && pwd -P)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
tmp=$(cd "$tmp" && pwd -P)

failures=0
fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

# The lines in laptop.sh that make ~/.ssh or set its mode.
# shellcheck disable=SC2016
lines=$(grep -E '^[[:space:]]*(mkdir|install|chmod)[[:space:]].*"\$HOME/\.ssh"$' "$root/laptop.sh" || true)

# run_lines HOME: run the ~/.ssh lines with the default umask.
run_lines() {
  HOME=$1 bash -euc "umask 022; $lines"
}

# laptop.sh makes a new ~/.ssh with mode 700.
home="$tmp/new"
mkdir -p "$home"
run_lines "$home"
if [ "$(stat -f %Lp "$home/.ssh" 2>/dev/null)" != 700 ]; then
  fail "new ~/.ssh mode: $(stat -f %Lp "$home/.ssh" 2>/dev/null)"
fi

# laptop.sh sets mode 700 on a ~/.ssh that exists with mode 755, and it
# keeps the files in it.
home="$tmp/old"
mkdir -p "$home/.ssh"
chmod 755 "$home/.ssh"
echo host >"$home/.ssh/known_hosts"
run_lines "$home"
if [ "$(stat -f %Lp "$home/.ssh")" != 700 ]; then
  fail "existing ~/.ssh mode: $(stat -f %Lp "$home/.ssh")"
fi
if [ "$(cat "$home/.ssh/known_hosts")" != host ]; then
  fail "existing ~/.ssh lost known_hosts"
fi

if [ "$failures" -gt 0 ]; then
  echo "$failures failures" >&2
  exit 1
fi
echo "ok ssh"
