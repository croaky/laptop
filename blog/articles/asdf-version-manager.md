# ASDF Version Manager

Programming languages release new versions.
Development, CI, or production environments may have
multiple versions of the same language installed.

A version manager program helps switch between versions
for a machine or project.

Often, these programs are language-specific.
Some examples are RVM, rbenv, and chruby for Ruby and nvm for Node.
They may have different installation, configuration, and commands.

[ASDF](https://github.com/asdf-vm/asdf) is a version manager
with a plugin system to support different languages while maintaining
a single installation, configuration, and command interface.

## Install version manager

I use a [laptop.sh script](laptop-sh)
to install or update system prerequisites
and then install or update ASDF:

```bash
if [ -d "$HOME/.asdf" ]; then
  (
    cd "$HOME/.asdf"
    git pull origin master
  )
else
  git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf"
fi
```

## Install languages

The script then installs or updates ASDF language plugins and languages:

```bash
asdf_plugin_update() {
  if ! asdf plugin-list | grep -Fq "$1"; then
    asdf plugin-add "$1" "$2"
  fi

  asdf plugin-update "$1"
}

asdf_plugin_update "go" "https://github.com/kennyp/asdf-golang"
asdf install go 1.11.5

asdf_plugin_update "nodejs" "https://github.com/asdf-vm/asdf-nodejs"
export NODEJS_CHECK_SIGNATURES=no
asdf install nodejs 11.10.0

asdf_plugin_update "python" "https://github.com/tuvistavie/asdf-python.git"
asdf install python 3.6.5

asdf_plugin_update "ruby" "https://github.com/asdf-vm/asdf-ruby"
asdf install ruby 2.6.1
```

Node has a special case:
the `NODEJS_CHECK_SIGNATURES=no` environment variable setting
skips [checking downloads against OpenPGP signatures][nodeuse].

[nodeuse]: https://github.com/asdf-vm/asdf-nodejs#use

## Configure

I manage my `PATH` in a my [shell profile][zshrc].
It contains:

[zshrc]: https://github.com/statusok/statusok/blob/master/dotfiles/shell/zshrc

```zsh
# Prepend programming language binaries via ASDF shims
PATH="$HOME/.asdf/bin:$PATH"
PATH="$HOME/.asdf/shims:$PATH"

export -U PATH
```

ASDF shims are one of the first things in my `PATH`.

ASDF shims need to be near the front of the `PATH`
in order to take precedence over any other installations
of the languages or binaries installed via the language:

```bash
% which go
~/.asdf/shims/go
% which node
~/.asdf/shims/node
% which python
~/.asdf/shims/python
% which ruby
~/.asdf/shims/ruby
```

Note, the ASDF README suggests:

```bash
. $HOME/.asdf/asdf.sh
```

This is an alternate approach for adding shims to `PATH`.
It also adds shell completions.

Given infrequent direct use of `asdf` commands
and excellent `asdf help` output,
I haven't needed shell completions.
I also prefer directly setting `PATH` for clarity and control.

## Configure

The laptop setup script symlinks ASDF-related [dotfiles]
from a Git repository to `$HOME`:

[dotfiles]: https://github.com/statusok/statusok/tree/master/dotfiles

```bash
(
  cd dotfiles
  ln -sf "$PWD/asdf/asdfrc" "$HOME/.asdfrc"
  ln -sf "$PWD/asdf/tool-versions" "$HOME/.tool-versions"
)
```

The contents of `~/.tool-versions` look like:

```bash
go 1.10
nodejs 8.9.0
python 3.6.5
ruby 2.5.1
```

ASDF uses these values as the "global" default language versions
on the machine. These values can be overridden by individual
projects with a `~/path/to/project/.tool-versions` file.

The contents of `~/.asdfrc` are:

```bash
legacy_version_file = yes
```

When set to `yes`, ASDF plugins will read "legacy" version filenames
such as `.ruby-version` for Ruby and `.nvmrc` or `.node-version` for Node.
This setting is useful when working on a project with teammates
who are using version managers other than ASDF.

## Usage

Once installed and configured,
users mostly don't need to interact with ASDF;
it will automatically read the needed versions for the working directory.

A few tips from `asdf help` include:

```bash
asdf current                  Display current version being used for all packages
asdf where <name> <version>   Display install path for an installed version
asdf which <name>             Display install path for current version
asdf local <name> <version>   Set the package local version
asdf global <name> <version>  Set the package global version
asdf list <name>              List installed versions of a package
asdf list-all <name>          List all versions of a package
asdf reshim <name> <version>  Recreate shims for version of a package
```

Those commands are often enough to debug most language-related problems.
For example:

```bash
% webpack
zsh: command not found: webpack
% asdf reshim nodejs 8.9.0
% which webpack
$HOME/.asdf/shims/webpack
```
