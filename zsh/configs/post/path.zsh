# Change into most common directories
export CDPATH="$CDPATH:$HOME/src/github.com"

# Append Go tools
export GOROOT="$(go env GOROOT)"
PATH="$PATH:$GOROOT/bin"

# Prepend Go binaries
export GOPATH="$HOME"
PATH="$GOPATH/bin:$PATH"

# Prepend JavaScript binaries
PATH="$(yarn global bin):$PATH"

# Prepend Chain binary
export CHAIN="$GOPATH/src/github.com/chain/chain"
PATH="$CHAIN/bin:$PATH"

# Prepend rbenv binary
PATH="$HOME/.rbenv/bin:$PATH"

# Prepend dotfiles binaries
PATH="$HOME/.bin:$PATH"

# Prepend Homebrew binaries
PATH="/usr/local/bin:$PATH"

# mkdir .git/safe in trusted project to add binstubs
PATH=".git/safe/../../bin:$PATH"

# Initialize rbenv
if command -v rbenv >/dev/null; then
  eval "$(rbenv init - --no-rehash)"
fi

export -U PATH
