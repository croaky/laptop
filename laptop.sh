#!/bin/bash

# ./laptop.sh

# - installs system packages
# - creates symlinks from `$OK/dotfiles` to `$HOME`
# - installs programming language runtimes
# - installs monospaced font

# This script can be run safely multiple times.
# It is tested on macOS Mojave (10.14).

set -eux

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

if ! command -v brew >/dev/null; then
  curl -fsS \
    'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby
  export PATH="/usr/local/bin:$PATH"
fi

brew analytics off
brew update-reset
brew bundle --no-lock --file=- <<EOF
tap "heroku/brew"
tap "homebrew/services"

brew "awscli"
brew "exercism"
brew "fzf"
brew "git"
brew "git-lfs"
brew "heroku"
brew "hub"
brew "imagemagick@6"
brew "jq"
brew "libyaml"
brew "openssl"
brew "protobuf"
brew "r"
brew "reattach-to-user-namespace"
brew "shellcheck"
brew "the_silver_searcher"
brew "tmux"
brew "vim"
brew "watch"
brew "watchman"
brew "zsh"

cask "aws-vault"
cask "kitty"
cask "ngrok"
cask "rstudio"
EOF

brew upgrade
brew cleanup

(
  cd "$OK/dotfiles"

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

  ln -sf "$PWD/shell/curlrc" "$HOME/.curlrc"
  ln -sf "$PWD/shell/hushlogin" "$HOME/.hushlogin"

  mkdir -p "$HOME/.config/kitty"
  ln -sf "$PWD/shell/kitty.conf" "$HOME/.config/kitty/kitty.conf"

  mkdir -p "$HOME/.ssh"
  ln -sf "$PWD/shell/ssh" "$HOME/.ssh/config"

  ln -sf "$PWD/shell/tmux.conf" "$HOME/.tmux.conf"
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

# Go
gover="1.13.6"
if ! go version | grep -Fq "$gover"; then
  sudo rm -rf /usr/local/go
  curl "https://dl.google.com/go/go$gover.darwin-amd64.tar.gz" | \
    sudo tar xz -C /usr/local
fi

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

# SF Mono
if ! echo ~/Library/Fonts/SFMono* > /dev/null; then
  cp -R /Applications/Utilities/Terminal.app/Contents/Resources/Fonts/. ~/Library/Fonts/
fi
