#!/bin/bash

# Test bin/git-trust and the trust rule in bin/goimportslocal.
#
# The fake goimports below writes a marker file. A marker file means
# that Go built and ran code that the repo chose. Each test uses a
# temporary HOME, so it does not change ~/.gitconfig.local or ~/go/bin.
set -euo pipefail

# A relative PATH entry from an older shell would run the fixtures'
# own programs in place of the real ones.
PATH=$(printf '%s' "$PATH" | tr ':' '\n' | grep '^/' | paste -sd: -)

root=$(cd "$(dirname "$0")/.." && pwd -P)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
tmp=$(cd "$tmp" && pwd -P)

# Keep the real Go caches, so that the tests need no network.
GOPATH=$(go env GOPATH)
GOMODCACHE=$(go env GOMODCACHE)
GOCACHE=$(go env GOCACHE)
export GOPATH GOMODCACHE GOCACHE
export GOTOOLCHAIN=local GOFLAGS='' GOBIN="$tmp/gobin"
export HOME="$tmp/home" GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com
export GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com
export MARKER="$tmp/marker"
mkdir -p "$HOME" "$GOBIN"

trust="$root/bin/git-trust"
failures=0
fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

# hostile_module DIR [pin]: a Go module whose go.mod replaces
# golang.org/x/tools with a local copy. Its goimports writes $MARKER.
# With "pin", go.mod also names goimports as a go tool.
hostile_module() {
  local dir=$1
  mkdir -p "$dir/x/cmd/goimports"
  {
    echo "module example.com/hostile"
    echo "go 1.24"
    if [ "${2:-}" = pin ]; then
      echo "tool golang.org/x/tools/cmd/goimports"
    fi
    echo "require golang.org/x/tools v0.0.0"
    echo "replace golang.org/x/tools => ./x"
  } >"$dir/go.mod"
  printf 'module golang.org/x/tools\ngo 1.24\n' >"$dir/x/go.mod"
  cat >"$dir/x/cmd/goimports/main.go" <<'GO'
package main

import (
	"io"
	"os"
)

func main() {
	os.WriteFile(os.Getenv("MARKER"), nil, 0o644)
	io.Copy(os.Stdout, os.Stdin)
}
GO
  printf 'package hostile\n' >"$dir/a.go"
  git -C "$dir" init -q
  git -C "$dir" add -A
  git -C "$dir" commit -q -m init
}

# Behavior: git trust records the main clone, and --check accepts the
# clone and its registered worktrees only.
main="$tmp/main"
hostile_module "$main" pin
git -C "$main" worktree add -q "$tmp/wt" -b wt
other="$tmp/other"
mkdir -p "$other"
git -C "$other" init -q
(cd "$tmp/wt" && "$trust") || fail "git trust failed in a worktree"
"$trust" --check "$main" || fail "--check rejects the trusted clone"
"$trust" --check "$main/x/cmd" || fail "--check rejects a subdirectory"
"$trust" --check "$tmp/wt" || fail "--check rejects a registered worktree"
if "$trust" --check "$other"; then
  fail "--check accepts an untrusted repo"
fi

# Boundary: a directory whose .git file points into the trusted repo,
# but which that repo does not list as a worktree, is not trusted.
forged="$tmp/forged"
mkdir -p "$forged"
echo "gitdir: $main/.git/worktrees/wt" >"$forged/.git"
if "$trust" --check "$forged"; then
  fail "--check accepts a forged .git file"
fi

# Behavior: --check accepts a worktree that git records with a
# relative path, from any directory.
rel="$tmp/rel"
mkdir -p "$rel"
git -C "$rel" init -q
git -C "$rel" commit -q --allow-empty -m init
git -C "$rel" worktree add -q --relative-paths "$tmp/relwt" -b relwt
(cd "$rel" && "$trust") || fail "git trust failed in the relative clone"
(cd / && "$trust" --check "$tmp/relwt") || fail "--check rejects a relative worktree"

# Boundary: git-trust reads a relative worktree path from the gitdir
# file's directory, not from the caller's. The gitdir file holds
# ../../../../relwt/.git. From four levels down in a hostile repo, the
# same text names a symlink back to the hostile repo's root.
lookalike="$tmp/lookalike"
mkdir -p "$lookalike/a/b/c/d"
git -C "$lookalike" init -q
ln -s "$lookalike" "$lookalike/relwt"
if (cd "$lookalike/a/b/c/d" && "$trust" --check .); then
  fail "--check reads a relative worktree path from the current directory"
fi

# Boundary: a module root whose name ends in a newline is not trusted.
# $(...) drops a trailing newline, and a symlink with the shorter name
# points into the trusted repo. Go builds no package in a directory
# with a newline, so the replaced tools copy sits outside it.
nl="$tmp/nl"$'\n'
hostile_module "$nl" pin
mv "$nl/x" "$tmp/nlx"
sed -i '' "s|=> ./x|=> $tmp/nlx|" "$nl/go.mod"
ln -s "$main" "$tmp/nl"
if "$trust" --check "$nl"; then
  fail "--check accepts a directory whose name ends in a newline"
fi
if "$trust" --check "$nl/x/cmd"; then
  fail "--check accepts a directory below a name that ends in a newline"
fi
rm -f "$MARKER"
(cd "$nl" && "$root/bin/goimportslocal" -srcdir "$nl" "$nl/a.go" </dev/null >/dev/null) ||
  fail "goimportslocal failed in a module whose name ends in a newline"
[ ! -e "$MARKER" ] || fail "goimportslocal ran repo code in a module whose name ends in a newline"

# Boundary: the repo's own config cannot mark the repo as trusted.
git -C "$other" config laptop.trusted "$other"
if "$trust" --check "$other"; then
  fail "--check reads the repo's own config"
fi

# Behavior: in an untrusted module that pins goimports, the formatter
# runs the pinned goimports and builds no repo code.
untrusted="$tmp/untrusted"
hostile_module "$untrusted" pin
rm -f "$MARKER"
(cd "$untrusted" && "$root/bin/goimportslocal" -srcdir "$untrusted" "$untrusted/a.go" </dev/null >/dev/null) ||
  fail "goimportslocal failed in an untrusted module"
[ ! -e "$MARKER" ] || fail "goimportslocal ran repo code in an untrusted module"

# Behavior: in a trusted module, the formatter keeps go tool, so the
# editor formats as the repo's own check does.
rm -f "$MARKER"
(cd "$main" && "$root/bin/goimportslocal" -srcdir "$main" "$main/a.go" </dev/null >/dev/null) ||
  fail "goimportslocal failed in a trusted module"
[ -e "$MARKER" ] || fail "goimportslocal did not run go tool in a trusted module"

# Boundary: with no goimports on PATH, the formatter installs nothing
# that the module resolves, and it fails.
fallback="$tmp/fallback"
hostile_module "$fallback"
gobin=$(dirname "$(command -v go)")
if (cd "$fallback" && PATH="/usr/bin:/bin:$gobin" \
  "$root/bin/goimportslocal" -srcdir "$fallback" "$fallback/a.go" </dev/null >/dev/null 2>&1); then
  fail "goimportslocal succeeded with no goimports on PATH"
fi
[ -z "$(ls -A "$GOBIN")" ] || fail "goimportslocal installed a binary built from the module"

[ "$failures" -eq 0 ] || exit 1
echo "ok trust_test"
