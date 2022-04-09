#!/bin/bash

# ./laptop.sh

# - installs system packages with Homebrew package manager
# - changes shell to Z shell (zsh)
# - creates symlinks for dotfiles to `$HOME`
# - installs programming language runtimes
# - installs or updates Vim plugins

# This script can be safely run multiple times.
# Tested with macOS Monterey (12.2) on arm64 (Apple Silicon)

set -eux

if [ "$(uname -m)" != "arm64" ]; then
 echo "laptop script only configured for M1 chip"
 exit 1
fi

# Symlinks
(
  ln -sf "$PWD/asdf/asdfrc" "$HOME/.asdfrc"
  ln -sf "$PWD/asdf/tool-versions" "$HOME/.tool-versions"

  ln -sf "$PWD/vim/vimrc" "$HOME/.vimrc"

  mkdir -p "$HOME/.vim/ftdetect"
  mkdir -p "$HOME/.vim/ftplugin"
  mkdir -p "$HOME/.vim/syntax"
  (
    cd vim
    ln -sf "$PWD/coc-settings.json" "$HOME/.vim/coc-settings.json"
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
  ln -sf "$PWD/ruby/irbrc" "$HOME/.irbrc"
  ln -sf "$PWD/ruby/rspec" "$HOME/.rspec"

  mkdir -p "$HOME/.config/kitty"
  ln -sf "$PWD/shell/kitty.conf" "$HOME/.config/kitty/kitty.conf"

  mkdir -p "$HOME/.ssh"
  ln -sf "$PWD/shell/ssh" "$HOME/.ssh/config"

  mkdir -p "$HOME/.config/bat"
  ln -sf "$PWD/shell/bat" "$HOME/.config/bat/config"

  ln -sf "$PWD/shell/curlrc" "$HOME/.curlrc"
  ln -sf "$PWD/shell/hushlogin" "$HOME/.hushlogin"
  ln -sf "$PWD/shell/tmux.conf" "$HOME/.tmux.conf"
  ln -sf "$PWD/shell/zshrc" "$HOME/.zshrc"

  ln -sf "$PWD/sql/psqlrc" "$HOME/.psqlrc"

  mkdir -p "$HOME/Library/Application Support/Code/User"
  ln -sf "$PWD/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
)

# Homebrew
BREW="/opt/homebrew"

if [ ! -d "$BREW" ]; then
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
fi

export PATH="$BREW/bin:$PATH"

brew analytics off
brew update-reset
brew bundle --no-lock --file=- <<EOF
tap "heroku/brew"
tap "homebrew/services"
tap "planetscale/tap"

brew "asdf"
brew "awscli"
brew "bat"
brew "crystal"
brew "fzf"
brew "gh"
brew "git"
brew "go"
brew "heroku"
brew "jq"
brew "libyaml"
brew "mysql-client"
brew "node"
brew "openssl"
brew "pgformatter"
brew "pscale"
brew "shellcheck"
brew "the_silver_searcher"
brew "tldr"
brew "tmux"
brew "tree"
brew "vim"
brew "watch"
brew "zsh"

cask "ngrok"
EOF

brew upgrade
brew cleanup

# Shell
if [ ! -d "/Applications/kitty.app" ]; then
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
fi

if [ "$(command -v zsh)" != "$BREW/bin/zsh" ] ; then
  sudo chown -R "$(whoami)" "$BREW/share/zsh" "$BREW/share/zsh/site-functions"
  chmod u+w "$BREW/share/zsh" "$BREW/share/zsh/site-functions"
  shellpath="$(command -v zsh)"

  if ! grep "$shellpath" /etc/shells > /dev/null 2>&1 ; then
    sudo sh -c "echo $shellpath >> /etc/shells"
  fi

  chsh -s "$shellpath"
fi

# Go
if ! command -v godoc &> /dev/null; then
  go get golang.org/x/tools/cmd/godoc
fi

# Deno
curl -fsSL https://deno.land/x/install/install.sh | sh
mkdir -p ~/.zsh
deno completions zsh > ~/.zsh/_deno

# Heroku Postgres
heroku plugins:install heroku-pg-extras

# ASDF
export PATH="$BREW/opt/asdf/bin:$BREW/opt/asdf/shims:$PATH"

# Ruby
if ! asdf plugin-list | grep -Fq "ruby"; then
  asdf plugin-add "ruby" "https://github.com/asdf-vm/asdf-ruby"
fi
asdf plugin-update "ruby"
asdf install ruby 3.0.3

# Vim
if [ -e "$HOME/.vim/autoload/plug.vim" ]; then
  vim -u "$HOME/.vimrc" +PlugUpgrade +qa
else
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim -u "$HOME/.vimrc" +PlugUpdate +PlugClean! +qa

# VS Code
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
