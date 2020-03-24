#!/bin/bash

# ./laptop.sh

# - installs system packages with Homebrew package manager
# - changes shell to Z shell (zsh)
# - creates symlinks from `$LAPTOP/dotfiles` to `$HOME`
# - installs or updates Vim plugins
# - installs programming language runtimes

# This script can be run safely multiple times.
# It is tested on macOS Mojave (10.14).

set -eux

# Homebrew packages
HOMEBREW_PREFIX="/usr/local"

if [ -d "$HOMEBREW_PREFIX" ]; then
  if ! [ -r "$HOMEBREW_PREFIX" ]; then
    sudo chown -R "$LOGNAME:admin" "$HOMEBREW_PREFIX"
  fi
else
  sudo mkdir "$HOMEBREW_PREFIX"
  sudo chflags norestricted "$HOMEBREW_PREFIX"
  sudo chown -R "$LOGNAME:admin" "$HOMEBREW_PREFIX"
fi

if ! command -v brew >/dev/null; then
  curl -fsS 'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby
  export PATH="/usr/local/bin:$PATH"
fi

brew analytics off
brew update-reset
brew bundle --no-lock --file=- <<EOF
tap "heroku/brew"
tap "homebrew/services"

brew "exercism"
brew "fzf"
brew "git"
brew "github/gh/gh"
brew "heroku"
brew "jq"
brew "libyaml"
brew "openssl"
brew "protobuf"
brew "shellcheck"
brew "the_silver_searcher"
brew "tldr"
brew "tmux"
brew "tree"
brew "vim"
brew "watch"
brew "watchman"
brew "zsh"

cask "kitty"
cask "ngrok"
EOF

brew upgrade
brew cleanup

# Z shell (zsh)
update_shell() {
  local shell_path;
  shell_path="$(command -v zsh)"

  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  chsh -s "$shell_path"
}

case "$SHELL" in
  */zsh)
    if [ "$(command -v zsh)" != "$HOMEBREW_PREFIX/bin/zsh" ] ; then
      update_shell
    fi
    ;;
  *)
    update_shell
    ;;
esac

# Symlinks
(
  cd "$LAPTOP/dotfiles"

  ln -sf "$PWD/asdf/asdfrc" "$HOME/.asdfrc"
  ln -sf "$PWD/asdf/tool-versions" "$HOME/.tool-versions"

  ln -sf "$PWD/editor/vimrc" "$HOME/.vimrc"

  mkdir -p "$HOME/.vim/ftdetect"
  mkdir -p "$HOME/.vim/ftplugin"
  mkdir -p "$HOME/.vim/syntax"
  (
    cd editor/vim
    for f in {ftdetect,ftplugin,syntax}/*; do
      ln -sf "$PWD/$f" "$HOME/.vim/$f"
    done
  )

  ln -sf "$PWD/git/gitconfig" "$HOME/.gitconfig"
  ln -sf "$PWD/git/gitignore" "$HOME/.gitignore"
  ln -sf "$PWD/git/gitmessage" "$HOME/.gitmessage"

  mkdir -p "$HOME/.bundle"
  ln -sf "$PWD/ruby/bundle/config" "$HOME/.bundle/config"
  ln -sf "$PWD/ruby/gemrc" "$HOME/.gemrc"
  ln -sf "$PWD/ruby/rspec" "$HOME/.rspec"

  mkdir -p "$HOME/.config/kitty"
  ln -sf "$PWD/shell/kitty.conf" "$HOME/.config/kitty/kitty.conf"

  mkdir -p "$HOME/.ssh"
  ln -sf "$PWD/shell/ssh" "$HOME/.ssh/config"

  ln -sf "$PWD/shell/curlrc" "$HOME/.curlrc"
  ln -sf "$PWD/shell/hushlogin" "$HOME/.hushlogin"
  ln -sf "$PWD/shell/tmux.conf" "$HOME/.tmux.conf"
  ln -sf "$PWD/shell/zshrc" "$HOME/.zshrc"

  ln -sf "$PWD/sql/psqlrc" "$HOME/.psqlrc"
)

# Vim
if [ -e "$HOME/.vim/autoload/plug.vim" ]; then
  vim -u "$HOME/.vimrc" +PlugUpgrade +qa
else
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim -u "$HOME/.vimrc" +PlugUpdate +PlugClean! +qa

# Go
gover="1.14"
if ! go version | grep -Fq "$gover"; then
  sudo rm -rf /usr/local/go
  curl "https://dl.google.com/go/go$gover.darwin-amd64.tar.gz" | \
    sudo tar xz -C /usr/local
fi

# ASDF
if [ -d "$HOME/.asdf" ]; then
  (
    cd "$HOME/.asdf"
    git fetch origin
    git reset --hard origin/master
  )
else
  git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf"
fi

asdf_plugin_update() {
  if ! asdf plugin-list | grep -Fq "$1"; then
    asdf plugin-add "$1" "$2"
  fi

  asdf plugin-update "$1"
}

# Node
asdf_plugin_update "nodejs" "https://github.com/asdf-vm/asdf-nodejs"
export NODEJS_CHECK_SIGNATURES=no
asdf install nodejs 13.7.0
asdf global nodejs 13.7.0
asdf reshim nodejs
npm config set scripts-prepend-node-path true

# Ruby
asdf_plugin_update "ruby" "https://github.com/asdf-vm/asdf-ruby"
asdf install ruby 2.7.0

# Python

asdf_plugin_update "python" "https://github.com/tuvistavie/asdf-python.git"
asdf install python 3.8.2
asdf global python 3.8.2

# Block ads
"$LAPTOP/bin/adblock"
