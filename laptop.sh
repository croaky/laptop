#!/bin/bash

# ./laptop.sh

# - terminals (Ghostty, Warp)
# - shells (nu, zsh)
# - symlinks for dotfiles to `$HOME`
# - text editor (Neovim)
# - programming language runtimes (Go, Node, Rust)
# - language servers (Bash, Go, HTML, Lua, TypeScript)
# - CLIs (awscli, bat, cb, fd, fzf, gh, git, rg, tree, ubi)
# - databases (Postgres dev and test clusters)

# This script can be safely run multiple times.
# Tested with macOS Tahoe on arm64.

set -eu

# Symlinks
(
  # CLI
  mkdir -p "$HOME/.config/bat/themes"
  ln -sf "$PWD/cli/bat.xml" "$HOME/.config/bat/themes/CatppuccinFrappe.tmTheme"
  mkdir -p "$HOME/.config/dprint"
  ln -sf "$PWD/cli/dprint.jsonc" "$HOME/.config/dprint/dprint.jsonc"
  mkdir -p "$HOME/.ssh"
  ln -sf "$PWD/cli/ssh" "$HOME/.ssh/config"

  # Git
  ln -sf "$PWD/git/gitconfig" "$HOME/.gitconfig"
  ln -sf "$PWD/git/gitignore" "$HOME/.gitignore"

  # Postgres
  ln -sf "$PWD/postgres/psqlrc" "$HOME/.psqlrc"

  # JavaScript
  ln -sf "$PWD/js/npmrc" "$HOME/.npmrc"

  # Shells
  ln -sf "$PWD/shell/hushlogin" "$HOME/.hushlogin"
  ln -sf "$PWD/shell/zshrc" "$HOME/.zshrc"

  # Terminals
  mkdir -p "$HOME/.config/ghostty"
  ln -sf "$PWD/term/ghostty" "$HOME/.config/ghostty/config"
  mkdir -p "$HOME/.warp/themes"
  ln -sf "$PWD/term/warp.yml" "$HOME/.warp/themes/catppuccin_frappe.yml"

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

PG_VERSION="${PG_VERSION:-17}"

brew analytics off
brew update-reset
brew bundle --file=- <<EOF
tap "CrunchyData/brew", trusted: true
tap "ubicloud/cli", trusted: true

cask "ghostty@tip"

brew "awscli"
brew "bash"
brew "bat"
brew "CrunchyData/brew/cb"
brew "fd"
brew "flock"
brew "fzf"
brew "gh"
brew "git"
brew "go"
brew "lua-language-server"
brew "neovim"
brew "node"
brew "postgresql@$PG_VERSION"
brew "ripgrep"
brew "rust" # cargo/rustc for ~/warp
brew "shellcheck"
brew "shfmt"
brew "stylua"
brew "tree"
brew "tree-sitter-cli" # parser compiler for nvim-treesitter
brew "ubicloud/cli/ubi"
brew "zsh"
EOF

brew upgrade
brew autoremove
brew cleanup

# Shells
add_to_shells() {
  local shell_path="$1"

  if [ -x "$shell_path" ] && ! grep "$shell_path" /etc/shells >/dev/null 2>&1; then
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
}

zsh_path="$BREW/bin/zsh"
add_to_shells "$zsh_path"

if [[ -d "$BREW/share/zsh" && -d "$BREW/share/zsh/site-functions" ]]; then
  if [[ "$(stat -f '%Su' "$BREW/share/zsh")" != "$(whoami)" ]]; then
    sudo chown -R "$(whoami)" "$BREW/share/zsh" "$BREW/share/zsh/site-functions"
  fi
  chmod u+w "$BREW/share/zsh" "$BREW/share/zsh/site-functions"
fi

# Bat
bat cache --build

# Go
go install golang.org/x/tools/cmd/deadcode@latest
go install golang.org/x/tools/cmd/godoc@latest
go install golang.org/x/tools/cmd/goimports@latest
go install golang.org/x/tools/gopls@latest

# NPM
# Node is here for the two language servers below, which are published
# only as npm packages, and for nvim-treesitter, whose install-time
# `tree-sitter generate` defaults to running node to read a grammar.js.
# Nothing else needs it: Go builds the JavaScript, tsgo typechecks it,
# and dprint formats it. A grammar's own check passes
# --js-runtime native and uses the QuickJS the CLI embeds instead.
npm install -g npm@latest

# Bash
npm install -g bash-language-server # uses shellcheck internally for linting diagnostics

# HTML
npm install -g vscode-langservers-extracted

# TypeScript
# Standalone tsgo binary from the GitHub release; no tsserver
TSGO_VERSION="7.0.2"
TSGO_DIR="$HOME/.local/share/tsgo"
if [ "$("$HOME/.local/bin/tsgo" --version 2>/dev/null)" != "Version $TSGO_VERSION" ]; then
  mkdir -p "$TSGO_DIR" "$HOME/.local/bin"
  curl -fsSL "https://github.com/microsoft/typescript-go/releases/download/typescript/v${TSGO_VERSION}/typescript-darwin-arm64.tgz" |
    tar -xz -C "$TSGO_DIR" --strip-components=1
  ln -sf "$TSGO_DIR/lib/tsc" "$HOME/.local/bin/tsgo"
fi

# dprint
# Standalone binary from the GitHub release; no prettier.
DPRINT_VERSION="0.55.2"
if [ "$("$HOME/.local/bin/dprint" --version 2>/dev/null)" != "dprint $DPRINT_VERSION" ]; then
  mkdir -p "$HOME/.local/bin"
  DPRINT_TMP="$(mktemp -d)"
  curl -fsSL "https://github.com/dprint/dprint/releases/download/${DPRINT_VERSION}/dprint-aarch64-apple-darwin.zip" -o "$DPRINT_TMP/dprint.zip"
  unzip -oq "$DPRINT_TMP/dprint.zip" -d "$DPRINT_TMP"
  install "$DPRINT_TMP/dprint" "$HOME/.local/bin/dprint"
  rm -rf "$DPRINT_TMP"
fi

# Neovim
LAZY_DIR="$HOME/.local/share/nvim/lazy/lazy.nvim"
if [ ! -d "$LAZY_DIR" ]; then
  git clone --filter=blob:none https://github.com/folke/lazy.nvim.git "$LAZY_DIR"
fi

nvim --headless "+Lazy! sync" +qa

# Postgres
export PATH="$BREW/opt/postgresql@$PG_VERSION/bin:$PATH"
if ! command -v initdb >/dev/null || ! command -v pg_ctl >/dev/null; then
  echo "initdb and/or pg_ctl not found in PATH"
  exit 1
fi

start_postgres_cluster() {
  local port="$1"
  local data_dir="$2"
  local log_file="$3"
  local opts="$4"

  mkdir -p "$(dirname "$data_dir")"
  mkdir -p "$(dirname "$log_file")"

  if [ ! -f "$data_dir/PG_VERSION" ]; then
    initdb -D "$data_dir" -U postgres -c maintenance_work_mem=2GB

    echo "timezone = 'UTC'" >>"$data_dir/postgresql.conf"
    echo "log_timezone = 'UTC'" >>"$data_dir/postgresql.conf"
  fi

  if pg_ctl -D "$data_dir" status >/dev/null 2>&1; then
    echo "Postgres is already running for data directory $data_dir"
    return
  fi

  if lsof -i "tcp:$port" >/dev/null 2>&1; then
    echo "Postgres port $port is already in use"
    return
  fi

  pg_ctl -D "$data_dir" -l "$log_file" -o "-p $port $opts" start
}

# dev databases
start_postgres_cluster 5432 \
  "$HOME/.local/share/postgres/data_dev" \
  "$HOME/.local/share/postgres/log_dev.log" \
  ""

# test databases
start_postgres_cluster 5433 \
  "$HOME/.local/share/postgres/data_test" \
  "$HOME/.local/share/postgres/log_test.log" \
  "-c fsync=off -c synchronous_commit=off -c full_page_writes=off"

# SQL formatter
go install github.com/croaky/pgfmt/cmd/pgfmt@latest
