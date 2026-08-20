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
brew "postgresql@$PG_VERSION"
brew "ripgrep"
brew "rust" # cargo/rustc for ~/warp
brew "shellcheck"
brew "shfmt"
brew "stylua"
brew "superhtml" # HTML language server and formatter
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

# Bash
# Language server built on mvdan.cc/sh that calls shellcheck for
# diagnostics. Replaces bash-language-server, which is npm only.
go install github.com/matkrin/bashd/cmd/bashd@latest

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

# Report whether a running cluster was started with settings other than
# the ones below. The settings reach a cluster through `pg_ctl -o` at
# start, so a cluster that is already up keeps whatever it was given,
# and editing this file alone changes nothing.
#
# `pg_ctl status` prints the postmaster command line with each token
# quoted on its own, so every wanted `name=value` should appear there
# verbatim. Counting `-c` tokens on both sides catches a setting deleted
# from this file, which searching for the wanted ones cannot see.
postgres_settings_differ() {
  local data_dir="$1"
  local running token wanted wanted_count=0 running_count
  local -a tokens

  running="$(pg_ctl -D "$data_dir" status 2>/dev/null | tr -s '[:space:]' ' ')"
  if [ -z "$running" ]; then
    return 0
  fi

  wanted="$(tr -s '[:space:]' ' ' <<<"$2")"
  read -ra tokens <<<"$wanted"

  for token in "${tokens[@]}"; do
    case "$token" in
    -c | -p | [0-9]*) continue ;;
    esac

    wanted_count=$((wanted_count + 1))

    if [[ "$running" != *"\"$token\""* ]]; then
      return 0
    fi
  done

  running_count="$(awk -F'"-c"' '{ print NF - 1 }' <<<"$running")"
  [ "$wanted_count" -ne "$running_count" ]
}

start_postgres_cluster() {
  local port="$1"
  local data_dir="$2"
  local log_file="$3"
  local opts="$4"

  mkdir -p "$(dirname "$data_dir")"
  mkdir -p "$(dirname "$log_file")"

  if [ ! -f "$data_dir/PG_VERSION" ]; then
    initdb -D "$data_dir" -U postgres

    echo "timezone = 'UTC'" >>"$data_dir/postgresql.conf"
    echo "log_timezone = 'UTC'" >>"$data_dir/postgresql.conf"
  fi

  if pg_ctl -D "$data_dir" status >/dev/null 2>&1; then
    if ! postgres_settings_differ "$data_dir" "-p $port $opts"; then
      echo "Postgres is already running with these settings for $data_dir"
      return
    fi

    echo "Restarting Postgres with changed settings for $data_dir"
    pg_ctl -D "$data_dir" stop
  elif lsof -i "tcp:$port" >/dev/null 2>&1; then
    echo "Postgres port $port is already in use"
    return
  fi

  pg_ctl -D "$data_dir" -l "$log_file" -o "-p $port $opts" start
}

# initdb sizes a cluster for a machine it knows nothing about, so out of
# the box a 128 GB laptop plans queries as though it had 4 GB and an
# aging disk. Pass the real numbers at start rather than writing them
# into postgresql.conf, so a data directory that already exists picks
# them up and this file stays the only place they are defined.
#
# shared_buffers is sized to hold a whole database rather than a share
# of RAM. Buffers beyond the largest database cache nothing.
# effective_cache_size and random_page_cost are planner inputs rather
# than allocations: the first tells it how much of a table it can expect
# to find in memory, the second is priced for a spinning disk by
# default and overcharges an index scan on an SSD. There is no
# effective_io_concurrency here because macOS has no posix_fadvise, so
# the server refuses to start with any value but 0.
pg_tuning="-c shared_buffers=8GB \
  -c effective_cache_size=96GB \
  -c work_mem=64MB \
  -c maintenance_work_mem=2GB \
  -c random_page_cost=1.1 \
  -c max_wal_size=16GB"

# A test database is built by the run that needs it, so it has nothing
# to lose to a crash and no reason to pay for durability.
#
# The dev cluster is deliberately not given these, even though it is
# restored daily and could afford to lose one. Four restores, two with
# these settings and two without, averaged 65s and 66s, and the spread
# within either pair was wider than the gap between them. There is no
# speed here to buy, and a cluster that survives a panic is worth more
# than nothing.
pg_durability="-c fsync=off -c synchronous_commit=off -c full_page_writes=off"

# dev databases
start_postgres_cluster 5432 \
  "$HOME/.local/share/postgres/data_dev" \
  "$HOME/.local/share/postgres/log_dev.log" \
  "$pg_tuning"

# test databases
start_postgres_cluster 5433 \
  "$HOME/.local/share/postgres/data_test" \
  "$HOME/.local/share/postgres/log_test.log" \
  "$pg_tuning $pg_durability"

# SQL formatter
go install github.com/croaky/pgfmt/cmd/pgfmt@latest
