#!/bin/bash

# This script can be safefuly run multiple times on the same machine.

# It installs, upgrades, or skips packages
# based on what is already installed on the machine.

# It creates symlinks of the dotfiles in this repo
# to the `~/` (`$HOME`) directory.

# Tested on macOS High Sierra (10.13).

set -ex

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

update_shell() {
  local shell_path;
  shell_path="$(which zsh)"

  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  chsh -s "$shell_path"
}

case "$SHELL" in
  */zsh)
    if [ "$(which zsh)" != "$HOMEBREW_PREFIX/bin/zsh" ] ; then
      update_shell
    fi
    ;;
  *)
    update_shell
    ;;
esac

if ! command -v brew >/dev/null; then
    curl -fsS \
      'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby

    export PATH="/usr/local/bin:$PATH"
fi

brew update
brew bundle --file=- <<EOF
tap "thoughtbot/formulae"
tap "homebrew/services"
tap "universal-ctags/universal-ctags"

brew "awscli"
brew "chromedriver", restart_service: :changed
brew "git"
brew "heroku"
brew "hub"
brew "imagemagick"
brew "jq"
brew "libyaml"
brew "openssl"
brew "parity"
brew "postgresql", restart_service: :changed
brew "protobuf"
brew "reattach-to-user-namespace"
brew "redis", restart_service: :changed
brew "shellcheck"
brew "the_silver_searcher"
brew "tmux"
brew "universal-ctags", args: ["HEAD"]
brew "vim", args: ["without-ruby"]
brew "watch"
brew "watchman"
brew "yarn"
brew "zsh"

cask "aws-vault"
cask "expo-xde"
cask "ngrok"
EOF

brew upgrade
brew cleanup
brew cask cleanup

(
  cd dotfiles

  ln -sf "$PWD/asdf/asdfrc" "$HOME/.asdfrc"
  ln -sf "$PWD/asdf/default-gems" "$HOME/.default-gems"

  ln -sf "$PWD/editor/vimrc" "$HOME/.vimrc"

  mkdir -p "$HOME/.vim/ftdetect"
  mkdir -p "$HOME/.vim/ftplugin"

  (
    cd editor/vim
    for f in {ftdetect,ftplugin}/*; do
      ln -sf "$PWD/$f" "$HOME/.vim/$f"
    done
  )

  mkdir -p "$HOME/.bundle"
  ln -sf "$PWD/ruby/bundle/config" "$HOME/.bundle/config"
  ln -sf "$PWD/ruby/gemrc" "$HOME/.gemrc"
  ln -sf "$PWD/ruby/rspec" "$HOME/.rspec"

  ln -sf "$PWD/search/ignore" "$HOME/.agignore"
  ln -sf "$PWD/search/ctags" "$HOME/.ctags"

  mkdir -p "$HOME/.zsh/completions"
  ln -sf "$PWD/shell/completions/exercism.zsh" "$HOME/.zsh/completions/exercism.zsh"

  ln -sf "$PWD/shell/curlrc" "$HOME/.curlrc"
  ln -sf "$PWD/shell/hushlogin" "$HOME/.hushlogin"
  ln -sf "$PWD/shell/zshenv" "$HOME/.zshenv"
  ln -sf "$PWD/shell/zshrc" "$HOME/.zshrc"

  ln -sf "$PWD/sql/psqlrc" "$HOME/.psqlrc"
)

if [ -e "$HOME/.vim/autoload/plug.vim" ]; then
  vim -u "$HOME/.vimrc" +PlugUpgrade +qa
else
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim -u "$HOME/.vimrc" +PlugUpdate +PlugClean! +qa

if [ -d "$HOME/.asdf" ]; then
  (
    cd "$HOME/.asdf"
    git pull origin master
  )
else
  git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf"
fi

# shellcheck source=/dev/null
. "$HOME/.asdf/asdf.sh"

asdf_plugin_update() {
  if ! asdf plugin-list | grep -Fq "$1"; then
    asdf plugin-add "$1" "$2"
  fi

  asdf plugin-update "$1"
}

asdf_plugin_update "ruby" "https://github.com/asdf-vm/asdf-ruby"
asdf install ruby 2.4.2
asdf global ruby 2.4.2

asdf_plugin_update "nodejs" "https://github.com/asdf-vm/asdf-nodejs"
export NODEJS_CHECK_SIGNATURES=no
asdf install nodejs 8.9.0
asdf global nodejs 8.9.0

asdf_plugin_update "go" "https://github.com/kennyp/asdf-golang"
asdf install go 1.10
asdf install go 1.9.3
asdf global go 1.9.3

asdf_plugin_update "java" "https://github.com/skotchpine/asdf-java"
asdf install java 8.161
asdf global java 8.161

asdf_plugin_update "maven" "https://github.com/skotchpine/asdf-maven"
asdf install maven 3.3.9
asdf global maven 3.3.9
