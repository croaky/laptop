#!/bin/bash

# ./laptop.sh

# - symlinks for dotfiles to `$HOME`
# - text editor (Neovim)
# - programming language runtimes (Go, Ruby, Node)
# - language servers (Bash, Go, HTML, Lua, Ruby, TypeScript)
# - CLIs (AWS, Crunchy Bridge, GitHub, Render)

# This script can be safely run multiple times.
# Tested with macOS Sequoia (15.13) on arm64 (M1 and M4 Max).

set -eu

# Symlinks
(
  # Git
  ln -sf "$PWD/git/gitconfig" "$HOME/.gitconfig"
  ln -sf "$PWD/git/gitignore" "$HOME/.gitignore"

  # Ruby
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
brew bundle --file=- <<EOF
tap "CrunchyData/brew"
tap "oven-sh/bun"

cask "ghostty@tip"
cask "ollama"

brew "awscli"
brew "bash"
brew "bat"
brew "CrunchyData/brew/cb"
brew "fd"
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
brew "postgresql@17"
brew "prettier"
brew "ripgrep"
brew "shellcheck"
brew "shfmt"
brew "stylua"
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
if [ "$(command -v zsh)" != "$BREW/bin/zsh" ]; then
  sudo chown -R "$(whoami)" "$BREW/share/zsh" "$BREW/share/zsh/site-functions"
  chmod u+w "$BREW/share/zsh" "$BREW/share/zsh/site-functions"
  shellpath="$(command -v zsh)"

  if ! grep "$shellpath" /etc/shells >/dev/null 2>&1; then
    sudo sh -c "echo $shellpath >> /etc/shells"
  fi

  chsh -s "$shellpath"
fi

# Go
go install golang.org/x/tools/cmd/godoc@latest
go install golang.org/x/tools/cmd/goimports@latest
go install golang.org/x/tools/gopls@latest

# AI via CLI
go install github.com/charmbracelet/mods@latest
go install github.com/croaky/mdembed@latest

# Ruby
v="3.4.1"
if [ ! -d "$HOME/.rubies/ruby-$v" ]; then
  RUBY_CONFIGURE_OPTS="--enable-yjit --with-openssl-dir=$(brew --prefix openssl@3)" ruby-build "$v" "$HOME/.rubies/ruby-$v"
fi

# NPM
npm install -g npm@latest

# Bash
npm install -g bash-language-server # uses shellcheck internally for linting diagnostics

# HTML
npm install -g vscode-langservers-extracted

# TypeScript
npm install -g typescript-language-server typescript

# Neovim
LAZY_DIR="$HOME/.local/share/nvim/lazy/lazy.nvim"
if [ ! -d "$LAZY_DIR" ]; then
  git clone --filter=blob:none https://github.com/folke/lazy.nvim.git "$LAZY_DIR"
fi

nvim --headless "+Lazy! sync" +qa

# Postgres
export PATH="$BREW/opt/postgresql@17/bin:$PATH"
if ! command -v initdb >/dev/null || ! command -v pg_ctl >/dev/null; then
  echo "initdb and/or pg_ctl not found in PATH"
  exit 1
fi

mkdir -p "$HOME/pg/bin"
curl -L https://github.com/supabase-community/postgres-language-server/releases/download/0.3.1/postgrestools_aarch64-apple-darwin -o "$HOME/pg/bin/postgrestools"
chmod +x "$HOME/pg/bin/postgrestools"

start_postgres_cluster() {
  local port="$1"
  local data_dir="$2"
  local log_file="$3"
  local opts="$4"

  mkdir -p "$(dirname "$data_dir")"
  mkdir -p "$(dirname "$log_file")"

  if [ ! -f "$data_dir/PG_VERSION" ]; then
    initdb -D "$data_dir" -U postgres
  fi

  if pg_ctl -D "$data_dir" status >/dev/null 2>&1; then
    echo "Postgres is already running for data directory $data_dir"
    return
  fi

  if lsof -i "tcp:$port" >/dev/null 2>&1; then
    echo "Port $port is already in use"
    return
  fi

  pg_ctl -D "$data_dir" -l "$log_file" -o "-p $port $opts" start
}

# test databases
start_postgres_cluster 5433 \
  "$HOME/.local/share/postgres/data_test" \
  "$HOME/.local/share/postgres/log_test.log" \
  "-c fsync=off -c synchronous_commit=off -c full_page_writes=off"

# dev databases
start_postgres_cluster 5432 \
  "$HOME/.local/share/postgres/data_dev" \
  "$HOME/.local/share/postgres/log_dev.log" \
  ""
