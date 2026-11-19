#!/bin/bash

# Test the trust rules in vim/init.lua. This script makes the fixture
# repos, then runs test/nvim_test.lua in a headless Neovim that loads
# the vim/init.lua of this checkout.
#
# A fake program in a fixture writes a marker file. A marker file
# means that Neovim ran repo code. The test uses a temporary HOME, so
# it does not change ~/.gitconfig.local.
set -euo pipefail

# A relative PATH entry from an older shell would run the fixtures'
# own programs in place of the real ones. The Neovim run below adds
# ./bin again on purpose.
PATH=$(printf '%s' "$PATH" | tr ':' '\n' | grep '^/' | paste -sd: -)

root=$(cd "$(dirname "$0")/.." && pwd -P)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
tmp=$(cd "$tmp" && pwd -P)

# Keep the real plugins, plugin caches, and Go caches, so that the
# test needs no network.
real=$HOME
GOPATH=$(go env GOPATH)
GOMODCACHE=$(go env GOMODCACHE)
GOCACHE=$(go env GOCACHE)
export GOPATH GOMODCACHE GOCACHE GOTOOLCHAIN=local
export XDG_CONFIG_HOME="$real/.config" XDG_DATA_HOME="$real/.local/share"
export XDG_CACHE_HOME="$real/.cache" XDG_STATE_HOME="$tmp/state"
export DPRINT_CACHE_DIR="$real/Library/Caches/dprint"
export HOME="$tmp/home" GIT_CONFIG_NOSYSTEM=1
export MARKERS="$tmp/markers"
mkdir -p "$MARKERS" "$HOME/.local/bin" "$HOME/.config/dprint"
ln -s "$real/.local/bin/dprint" "$HOME/.local/bin/dprint"
ln -s "$real/.config/dprint/dprint.jsonc" "$HOME/.config/dprint/dprint.jsonc"

# fixture DIR: a repo with a fake git and dprint that write markers, a
# go.mod that pins pgfmt, and a dprint.json that sets indentWidth 8.
fixture() {
  local dir=$1
  mkdir -p "$dir/bin" "$dir/node_modules/.bin"
  git -C "$dir" init -q
  printf '#!/bin/sh\ntouch "%s/git"\n' "$MARKERS" >"$dir/bin/git"
  printf '#!/bin/sh\ntouch "%s/dprint"\ncat\n' "$MARKERS" >"$dir/node_modules/.bin/dprint"
  chmod +x "$dir/bin/git" "$dir/node_modules/.bin/dprint"
  printf 'module example.com/fixture\n\ngo 1.24\n\ntool github.com/croaky/pgfmt/cmd/pgfmt\n' >"$dir/go.mod"
  local json
  json=$(grep -o '"https://plugins.dprint.dev/json-[^"]*"' "$real/.config/dprint/dprint.jsonc")
  printf '{"indentWidth": 8, "plugins": [%s]}\n' "$json" >"$dir/dprint.json"
  printf '{\n"a": {\n"b": 1\n}\n}\n' >"$dir/x.json"
  printf 'select 1;\n' >"$dir/q.sql"
}

export UNTRUSTED="$tmp/untrusted" TRUSTED="$tmp/trusted"
fixture "$UNTRUSTED"
fixture "$TRUSTED"

# A trusted repo with no dprint config.
export BARE="$tmp/bare"
mkdir -p "$BARE"
git -C "$BARE" init -q
printf '{\n"a": {\n"b": 1\n}\n}\n' >"$BARE/x.json"
printf 'select 1;\n' >"$BARE/q.sql"

# The name of a symlink in the untrusted repo, whose go.mod pins
# pgfmt, to the trusted repo with no go.mod. test/nvim_test.lua makes
# it after it names the buffer, because Neovim resolves a symlink when
# it opens a file.
export LINKED="$UNTRUSTED/link"

# A trusted repo with no go.mod, below a directory whose go.mod pins
# pgfmt.
export NESTED="$tmp/outer/inner"
mkdir -p "$NESTED"
cp "$TRUSTED/go.mod" "$tmp/outer/go.mod"
git -C "$NESTED" init -q
printf 'select 1;\n' >"$NESTED/q.sql"

if [ -x "$root/bin/git-trust" ]; then
  (cd "$TRUSTED" && "$root/bin/git-trust")
  (cd "$BARE" && "$root/bin/git-trust")
  (cd "$NESTED" && "$root/bin/git-trust")
fi

# Start Neovim in the untrusted repo with a relative entry on PATH, as
# an old shell config set it.
cd "$UNTRUSTED"
PATH="./bin:$PATH" nvim --headless -u "$root/vim/init.lua" \
  -c "luafile $root/test/nvim_test.lua"
