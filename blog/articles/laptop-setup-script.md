# Laptop Setup Script

Since 2011, I've been the primary maintainer of [Laptop], a shell script which
turns a Mac OS X laptop into an awesome development machine.

[Laptop]: https://github.com/thoughtbot/laptop

Instead of copying and pasting a series of steps from a blog post,
a better approach to setting up a machine as a software development environment
is to leverage automation and the open source community
to save time and get a more stable result.

## Install

Download, review, then execute the script:

```sh
curl --remote-name https://raw.githubusercontent.com/thoughtbot/laptop/master/mac
less mac
sh mac 2>&1 | tee ~/laptop.log
```

Optionally, [install thoughtbot/dotfiles][dotfiles].

[dotfiles]: https://github.com/thoughtbot/dotfiles#install

## How it works

The script should take less than 15 minutes to install (depending on the
machine).

The [mac] script is short. It is intended to be human-readable
so that we know exactly what is installed and idempotent in case an error
requires the script to be run two or more times.

[mac]: https://github.com/thoughtbot/laptop/blob/master/mac

## What it sets up

Laptop currently sets up these common components:

* Zsh for the Unix shell
* A systems package manager (Homebrew)
* A Ruby version manager (rbenv)
* A Ruby installer (ruby-build)
* The latest stable version of Ruby
* A Ruby package manager (Bundler)
* A JavaScript package manager (NPM)
* Our most commonly-needed databases (Postgres and Redis)
* ImageMagick for cropping and resizing images
* Qt for headless JavaScript testing via Capybara Webkit
* A fuzzy finder (The Silver Searcher)
* A terminal multiplexer (tmux)
* A dotfile manager (rcm)
* CLIs for interacting with GitHub and Heroku

## Extending the script

Individuals can add their own customizations in `~/.laptop.local`. An example
`~/.laptop.local` might look like this:

```bash
#!/bin/sh

fancy_echo "Upgrading Homebrew formulae ..."
brew upgrade

brew bundle --file=- <<EOF
brew "go"
brew "neovim/neovim/neovim"
brew "shellcheck"
brew "watch"

cask "ngrok"
EOF

fancy_echo "Cleaning up old Homebrew formulae ..."
brew cleanup
brew cask cleanup

if [ -r "$HOME/.rcrc" ]; then
  fancy_echo "Updating dotfiles ..."
  rcup
fi
```

The `~/.laptop.local` script can take advantage of the Laptop script's shared
functions and exit trap to provide better script output and aid debugging.

[prep]: https://github.com/thoughtbot/laptop/tree/master/common-components

## What's next

After using Laptop to set up a development machine, a great next step is to use
[thoughtbot/dotfiles][dotfiles] to configure Vim, Zsh, Git, and Tmux with
well-tested settings that we've evolved since 2011.

[dotfiles]: https://github.com/thoughtbot/dotfiles

Our dotfiles use the same `~/*.local` convention as the Laptop script in order
to [manage team and personal dotfiles together with rcm][rcm].

[rcm]: combine-team-and-personal-dotfiles-with-rcm
