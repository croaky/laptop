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
brew bundle --no-lock --file=- <<EOF
tap "CrunchyData/brew"
tap "oven-sh/bun"

cask "ghostty@tip"
cask "ollama"

brew "awscli"
brew "bat"
brew "CrunchyData/brew/cb"
brew "fd"
brew "fzf"
brew "gh"
brew "git"
brew "go"
brew "jq"
brew "libpq"
brew "lua-language-server"
brew "neovim"
brew "node"
brew "oven-sh/bun/bun"
brew "pgformatter"
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

# Bash
npm install -g bash-language-server # uses shellcheck internally for linting diagnostics

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
os=darwin
arch=arm64v8
version="17.2.0"

mkdir -p "$HOME/.local/bin"
cd "$HOME/.local"

if [ ! -x "$HOME/.local/bin/postgres" ]; then
  tmp_jar=$(mktemp /tmp/pg.XXXXXX.jar)
  curl -s -L "https://repo1.maven.org/maven2/io/zonky/test/postgres/embedded-postgres-binaries-$os-$arch/$version/embedded-postgres-binaries-$os-$arch-$version.jar" -o "$tmp_jar"
  unzip -p "$tmp_jar" "postgres-$os-*.txz" | tar -xJf - -C "$HOME/.local/bin"
  rm -f "$tmp_jar"
fi

export PATH="$HOME/.local/bin:$PATH"
if ! command -v initdb >/dev/null || ! command -v pg_ctl >/dev/null; then
  echo "initdb and/or pg_ctl not found in PATH"
  exit 1
fi

start_postgres_cluster() {
  local port="$1"
  local data_dir="$2"
  local log_file=$3
  local opts=$4

  if [ ! -f "$data_dir/PG_VERSION" ]; then
    initdb -D "$data_dir" -U postgres
  fi

  if pg_ctl -D "$data_dir" status >/dev/null 2>&1; then
    echo "Postgres already running for data directory $data_dir"
    return
  fi

  if lsof -i "tcp:$port" >/dev/null 2>&1; then
    echo "Postgres already running on port $port"
    return
  fi

  pg_ctl -D "$data_dir" -l "$log_file" -o "-p $port $opts" start
}

# test databases
start_postgres_cluster 5433 \
  "$HOME/.local/share/postgres/data_test" \
  "$HOME/.local/share/postgres/log_test.log" \
  "-c shared_buffers=12MB -c fsync=off -c synchronous_commit=off -c full_page_writes=off -c log_line_prefix='%d ::LOG::'"

# dev databases
start_postgres_cluster 5432 \
  "$HOME/.local/share/postgres/data_dev" \
  "$HOME/.local/share/postgres/log_dev.log" \
  "-p 5432 -c log_line_prefix='%d ::LOG::'"
