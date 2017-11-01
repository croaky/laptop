# Change into most common directories
export CDPATH="$CDPATH:$HOME/src/github.com"

# Prepend Go binaries, `brew info go`
export GOPATH="$HOME"
export GOROOT="/usr/local/opt/go/libexec"
PATH="$GOPATH/bin:$PATH"
PATH="$GOROOT/bin:$PATH"

# Prepend Chain binary
export CHAIN="$GOPATH/src/chain"
PATH="$CHAIN/bin:$PATH"

# Prepend JavaScript binaries
PATH="$(yarn global bin):$PATH"

# Prepend dotfiles binaries
PATH="$HOME/.bin:$PATH"

# Prepend Homebrew binaries
PATH="/usr/local/bin:$PATH"

# Prepend programming language binaries via ASDF shims
if [ -d "$HOME/.asdf" ]; then
  source $HOME/.asdf/asdf.sh
fi

# mkdir .git/safe in trusted project to add binstubs
PATH=".git/safe/../../bin:$PATH"

export -U PATH
