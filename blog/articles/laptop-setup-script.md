# Laptop Setup Script

From 2011-2017,
I was the primary maintainer of [thoughtbot/laptop],
a shell script which sets up a Mac OS X machine
as a sofware development environment.

[thoughtbot/laptop]: https://github.com/thoughtbot/laptop

I now work on the open source
[Status OK monorepo](https://github.com/statusok/statusok),
which contains a descedent of the thoughtbot/laptop script,
[laptop.sh](https://github.com/statusok/statusok/blob/master/laptop.sh).
It couples the setup script to a set of dotfiles in the repo.

## Install

Set the `OK` environment variable to a directory of your choice:

```
export OK="$HOME/src/statusok"
```

Clone onto laptop:

```
git clone https://github.com/statusok/statusok.git $OK
cd $OK
```

Review, then run, the script:

```
less laptop.sh
./laptop.sh
```

## What it sets up

The script is tested on macOS High Sierra (10.13).
It:

* uses [Homebrew] to install or upgrade system packages
  such as Git, Postgres, and Vim
* creates or updates symlinks from `$OK/dotfiles` to `$HOME`
* uses [ASDF] to install or update programming languages
  such as Ruby, Node, and Go

[Homebrew]: https://brew.sh/
[ASDF]: https://github.com/asdf-vm/asdf

The script should take about 10 minutes to install on a fresh machine.

This script can be run safely multiple times.
I run it most working mornings.
