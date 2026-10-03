#!/bin/zsh

# Test the Git helpers without contacting a server.
set -eu

root=${0:A:h:h}
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
export REAL_GIT=$(command -v git)
export GIT_CONFIG_GLOBAL="$tmp/gitconfig"
export GIT_CONFIG_NOSYSTEM=1
export CALLS="$tmp/calls"
export CHECKOUT_DIR="$tmp/tree with spaces"
export MAIN_DIR="$tmp/repo"
mkdir -p "$tmp/bin" "$CHECKOUT_DIR" "$MAIN_DIR"
export PATH="$tmp/bin:$PATH"
unset SOCKEYE_URL

cat > "$tmp/bin/soc" <<'SH'
#!/bin/sh
printf '%s\n' soc "${SOCKEYE_URL:-}" "$@" > "$CALLS"
[ "${FAIL_ACTION:-}" != "${1:-}" ] || exit 42
[ "${1:-}" != checkout ] || printf '%s\n' "$CHECKOUT_DIR"
SH
cat > "$tmp/bin/git" <<'SH'
#!/bin/sh
case "$1" in
  create-tree)
    printf '%s\n' git "$@" > "$CALLS"
    [ "${FAIL_ACTION:-}" != create-tree ] || exit 42
    printf '%s\n' "$CHECKOUT_DIR"
    ;;
  delete-tree)
    printf '%s\n' delete-tree >> "$CALLS"
    printf '%s\n' "$MAIN_DIR"
    ;;
  *) exec "$REAL_GIT" "$@" ;;
esac
SH
chmod +x "$tmp/bin/"*
git init -q "$MAIN_DIR"
cd "$MAIN_DIR"
source <(sed -n '/^# Git$/,/^# Bat$/p' "$root/shell/zshrc")

eq() {
  if [[ "$1" != "$2" ]]; then
    print -ru2 -- "$3: got ${(qqq)1}, want ${(qqq)2}"
    exit 1
  fi
}

git config --file "$GIT_CONFIG_GLOBAL" sockeye.url https://default.example.com
git config --file "$GIT_CONFIG_GLOBAL" sockeye.dc.url https://personal.example.com
git config --file "$GIT_CONFIG_GLOBAL" sockeye.ivp.url https://work.example.com/
git config remote.origin.url https://personal.example.com/git/soc.git
export SOCKEYE_URL=https://wrong.example.com
createtree SOC-1
eq "$PWD" "$CHECKOUT_DIR" 'personal checkout directory'
eq "$(<"$CALLS")" $'soc\nhttps://personal.example.com\ncheckout\nSOC-1' 'personal checkout routing'
eq "$SOCKEYE_URL" https://wrong.example.com 'checkout keeps caller environment'

cd "$MAIN_DIR"
git config remote.origin.url https://work.example.com/git/ci.git
createtree CI-1
eq "$(<"$CALLS")" $'soc\nhttps://work.example.com\ncheckout\nCI-1' 'work checkout routing'

cd "$MAIN_DIR"
git config remote.origin.url https://default.example.com/git/repo.git
createtree
eq "$(<"$CALLS")" $'soc\nhttps://default.example.com\ncheckout' 'default instance routing'

cd "$MAIN_DIR"
git config remote.origin.url git@github.com:example/repo.git
createtree 'topic with spaces'
eq "$(<"$CALLS")" $'git\ncreate-tree\ntopic with spaces' 'ordinary git fallback'

cd "$MAIN_DIR"
git config remote.origin.url https://work.example.com.evil/git/ci.git
createtree topic
eq "$(<"$CALLS")" $'git\ncreate-tree\ntopic' 'host boundary'

cd "$MAIN_DIR"
git config remote.origin.url https://personal.example.com/git/soc.git
export FAIL_ACTION=checkout
if createtree SOC-3; then
  print -ru2 'failed checkout changed the directory'
  exit 1
fi
eq "$PWD" "$MAIN_DIR" 'checkout failure keeps directory'
unset FAIL_ACTION

soc-ivp login
eq "$(<"$CALLS")" $'soc\nhttps://work.example.com\nlogin' 'explicit work wrapper'
soc-dc show SOC-1
eq "$(<"$CALLS")" $'soc\nhttps://personal.example.com\nshow\nSOC-1' 'explicit personal wrapper'
eq "$SOCKEYE_URL" https://wrong.example.com 'wrapper keeps caller environment'
git config --file "$GIT_CONFIG_GLOBAL" --unset sockeye.dc.url
if soc-dc login 2>/dev/null; then
  print -ru2 'missing instance configuration was accepted'
  exit 1
fi
git config --file "$GIT_CONFIG_GLOBAL" sockeye.dc.url https://personal.example.com

git config remote.origin.url https://work.example.com/git/ci.git
mergetree CI-4
eq "$(<"$CALLS")" $'soc\nhttps://work.example.com\nmerge\nCI-4\ndelete-tree' 'merge routing'
closetree CI-5
eq "$(<"$CALLS")" $'soc\nhttps://work.example.com\nclose\nCI-5\ndelete-tree' 'close routing'
export FAIL_ACTION=merge
if mergetree CI-6; then
  print -ru2 'failed merge removed the worktree'
  exit 1
fi
eq "$(<"$CALLS")" $'soc\nhttps://work.example.com\nmerge\nCI-6' 'merge failure keeps worktree'
unset FAIL_ACTION

git config remote.origin.url git@github.com:example/repo.git
if mergetree topic 2>/dev/null; then
  print -ru2 'ordinary git clone used a default change server'
  exit 1
fi

print 'Git helper tests pass.'
