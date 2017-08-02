#!/usr/bin/env zsh

# load custom executable functions
for function in ~/.zsh/functions/*; do
  source $function
done

# extra files in ~/.zsh/configs/pre , ~/.zsh/configs , and ~/.zsh/configs/post
# these are loaded first, second, and third, respectively.
_load_settings() {
  _dir="$1"
  if [ -d "$_dir" ]; then
    if [ -d "$_dir/pre" ]; then
      for config in "$_dir"/pre/**/*(N-.); do
        . $config
      done
    fi

    for config in "$_dir"/**/*(N-.); do
      case "$config" in
        "$_dir"/pre/*)
          :
          ;;
        "$_dir"/post/*)
          :
          ;;
        *)
          if [ -f $config ]; then
            . $config
          fi
          ;;
      esac
    done

    if [ -d "$_dir/post" ]; then
      for config in "$_dir"/post/**/*(N-.); do
        . $config
      done
    fi
  fi
}
_load_settings "$HOME/.zsh/configs"

# Load aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# Clone a Git repo into Go-compatible directory structure.
# clone https://github.com/statusok/eng
function clone() {
  host=$(echo "$1" | cut -d / -f 3)
  user=$(echo "$1" | cut -d / -f 4)
  repo=$(echo "$1" | cut -d / -f 5)

  cd "$GOPATH/src/$host"
  mkdir -p "$user"
  cd "$user"
  git clone "git@$host:$user/$repo".git
  cd "$repo"
}
