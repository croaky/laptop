#!/bin/zsh

# Test that shell/zshrc runs no program from the current directory.
# Each fake program in the project bin writes a marker file. A marker
# file means that the shell ran repo code.
set -eu

# A relative PATH entry from an older shell would run the fixture's
# own git in place of the real one.
path=(${(M)path:#/*})

root=${0:A:h:h}
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
tmp=${tmp:A}

project="$tmp/project"
markers="$tmp/markers"
mkdir -p "$project/bin" "$markers" "$tmp/home"
git -C "$project" init -q
for name in git git-current-branch soc; do
  print -r -- "#!/bin/sh
touch '$markers/$name'" > "$project/bin/$name"
  chmod +x "$project/bin/$name"
done

failures=0
fail() {
  print -ru2 -- "FAIL: $1"
  (( failures += 1 ))
}

# Start a shell in the project, as a user does after a clone or a
# checkout. The inherited PATH also has a relative entry, as an older
# shell or a terminal app can pass one on.
out=$(cd "$project" && HOME="$tmp/home" PATH="./inherited:$PATH" \
  zsh -f -c "source '$root/shell/zshrc'; print -rl -- \$path; git_prompt_info >/dev/null")

# Behavior: the exported PATH has only absolute directories.
relative=$(print -rl -- "${(f)out}" | grep -v '^/' || true)
[[ -z "$relative" ]] || fail "PATH has a relative entry: ${(f)relative}"

# Behavior: drawing the prompt runs no project git or git-current-branch.
[[ ! -e "$markers/git" ]] || fail "the prompt ran ./bin/git"
[[ ! -e "$markers/git-current-branch" ]] || fail "the prompt ran ./bin/git-current-branch"

# Behavior: shell start-up runs no project soc.
[[ ! -e "$markers/soc" ]] || fail "start-up ran ./bin/soc"

(( failures == 0 )) || exit 1
print -- "ok zshrc_test"
