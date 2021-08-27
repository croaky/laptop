#!/bin/bash

# ./laptop.sh

# - installs system packages with Homebrew package manager
# - changes shell to Z shell (zsh)
# - creates symlinks for dotfiles to `$HOME`
# - installs programming language runtimes
# - installs or updates Vim plugins

# This script can be safely run multiple times.
# Tested with Big Sur (11.3) on arm64 (Apple Silicon) and x86_64 (Intel) chips.

set -eux

# arm64 or x86_64
arch="$(uname -m)"

# Homebrew
if [ "$arch" = "arm64" ]; then
  BREW="/opt/homebrew"
else
  BREW="/usr/local"
fi

if [ ! -d "$BREW" ]; then
  sudo mkdir -p "$BREW"
  sudo chflags norestricted "$BREW"
  sudo chown -R "$LOGNAME:admin" "$BREW"
  curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$BREW"
fi

export PATH="$BREW/bin:$PATH"

brew analytics off
brew update-reset
brew bundle --no-lock --file=- <<EOF
tap "heroku/brew"
tap "homebrew/services"
tap "planetscale/tap"

brew "awscli"
brew "bat"
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
cask "r"
cask "rstudio"
EOF

brew upgrade
brew cleanup

# build kitty from source until Homebrew kitty works for M1
(
  mkdir -p "$HOME/src/github.com/kovidgoyal"
  cd "$HOME/src/github.com/kovidgoyal"
  rm -rf "kitty"
  git clone https://github.com/kovidgoyal/kitty
  cd kitty
  make app
  rm -rf /Applications/kitty.app
  mv kitty.app /Applications
)

# zsh
update_shell() {
  sudo chown -R "$(whoami)" "$BREW/share/zsh" "$BREW/share/zsh/site-functions"
  chmod u+w "$BREW/share/zsh" "$BREW/share/zsh/site-functions"
  shellpath="$(command -v zsh)"

  if ! grep "$shellpath" /etc/shells > /dev/null 2>&1 ; then
    sudo sh -c "echo $shellpath >> /etc/shells"
  fi

  chsh -s "$shellpath"
}

case "$SHELL" in
  */zsh)
    if [ "$(command -v zsh)" != "$BREW/bin/zsh" ] ; then
      update_shell
    fi
    ;;
  *)
    update_shell
    ;;
esac

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

# Go
if ! command -v godoc &> /dev/null; then
  go get golang.org/x/tools/cmd/godoc
fi

# Deno
curl -fsSL https://deno.land/x/install/install.sh | sh
mkdir -p ~/.zsh
deno completions zsh > ~/.zsh/_deno

# Deno Deploy https://github.com/denoland/deployctl
deno install --allow-read --allow-write --allow-env --allow-net --allow-run --no-check -r -f https://deno.land/x/deploy/deployctl.ts

# Heroku Postgres
heroku plugins:install heroku-pg-extras

# ASDF
if [ -d "$HOME/.asdf" ]; then
  (
    cd "$HOME/.asdf"
    git fetch origin
    git reset --hard origin/master
  )
else
  gh repo clone asdf-vm/asdf "$HOME/.asdf"
fi
PATH="$HOME/.asdf/bin:$PATH"
PATH="$HOME/.asdf/shims:$PATH"
export PATH

# Ruby
if ! asdf plugin-list | grep -Fq "ruby"; then
  asdf plugin-add "ruby" "https://github.com/asdf-vm/asdf-ruby"
fi
asdf plugin-update "ruby"
asdf install ruby 2.7.3
asdf install ruby 3.0.1

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
