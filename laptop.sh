#!/bin/bash

# ./laptop.sh

# - symlinks for dotfiles to `$HOME`
# - text editor (Neovim)
# - programming language runtimes (Go, Ruby, Node)
# - language servers (HTML, SQL)
# - CLIs (AWS, Crunchy Bridge, GitHub, Render)

# This script can be safely run multiple times.
# Tested with macOS Sequoia (15.11) on arm64 (Apple M4 Max)

set -eux

# Symlinks
(
  # Git
  ln -sf "$PWD/git/gitconfig" "$HOME/.gitconfig"
  ln -sf "$PWD/git/gitignore" "$HOME/.gitignore"

  # Ruby
  mkdir -p "$HOME/.bundle"
  ln -sf "$PWD/ruby/bundle/config" "$HOME/.bundle/config"
  ln -sf "$PWD/ruby/gemrc" "$HOME/.gemrc"
  ln -sf "$PWD/ruby/irbrc" "$HOME/.irbrc"
  ln -sf "$PWD/ruby/rspec" "$HOME/.rspec"

  # Shell
  mkdir -p "$HOME/.config/bat"
  ln -sf "$PWD/shell/bat" "$HOME/.config/bat/config"
  ln -sf "$PWD/shell/hushlogin" "$HOME/.hushlogin"
  mkdir -p "$HOME/.config/ghostty"
  ln -sf "$PWD/shell/ghostty" "$HOME/.config/ghostty/config"
  ln -sf "$PWD/shell/psqlrc" "$HOME/.psqlrc"
  mkdir -p "$HOME/.ssh"
  ln -sf "$PWD/shell/ssh" "$HOME/.ssh/config"
  ln -sf "$PWD/shell/tmux.conf" "$HOME/.tmux.conf"
  ln -sf "$PWD/shell/zshrc" "$HOME/.zshrc"

  # Vim
  mkdir -p "$HOME/.config/nvim"
  ln -sf "$PWD/vim/init.lua" "$HOME/.config/nvim/init.lua"
)

# Homebrew
BREW="/opt/homebrew"

if [ ! -d "$BREW" ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

export PATH="$BREW/bin:$PATH"

brew analytics off
brew update-reset
brew bundle --no-lock --file=- <<EOF
tap "CrunchyData/brew"
tap "oven-sh/bun"

brew "awscli"
brew "bat"
brew "CrunchyData/brew/cb"
brew "fzf"
brew "gh"
brew "git"
brew "go"
brew "jq"
brew "lua-language-server"
brew "neovim"
brew "node"
brew "oven-sh/bun/bun"
brew "pgformatter"
brew "prettier"
brew "shellcheck"
brew "stylua"
brew "the_silver_searcher"
brew "tldr"
brew "tmux"
brew "tree"
brew "tree-sitter"
brew "watch"
brew "zsh"

# https://github.com/rbenv/ruby-build/wiki
brew "gmp"
brew "libyaml"
brew "openssl@3"
brew "readline"
brew "ruby-build"
brew "rust" # https://github.com/ruby/ruby/blob/master/doc/yjit/yjit.md
EOF

brew upgrade
brew autoremove
brew cleanup

# Shell
brew install --cask ghostty@tip

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
  go install golang.org/x/tools/cmd/godoc@latest
fi

# Ruby
v="3.4.1"
if [ ! -d "$HOME/.rubies/ruby-$v" ]; then
  RUBY_CONFIGURE_OPTS="--enable-yjit --with-openssl-dir=$(brew --prefix openssl@3)" ruby-build "$v" "$HOME/.rubies/ruby-$v"
fi

# HTML
npm install -g vscode-langservers-extracted

# TypeScript
npm install -g typescript-language-server typescript

# Neovim with Packer
PACKER_DIR="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"

if [ ! -d "$PACKER_DIR" ]; then
  git clone --depth 1 https://github.com/wbthomason/packer.nvim "$PACKER_DIR"
fi

nvim --headless -c 'packadd packer.nvim' -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

# Treesitter
nvim --headless -c 'packadd packer.nvim' -c 'TSUpdateSync' -c 'quitall'
