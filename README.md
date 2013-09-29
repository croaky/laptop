croaky dotfiles
===============

I use [thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles) and
croaky/dotfiles together using the `*.local` convention described in
thoughtbot/dotfiles.

Requirements
------------

Set zsh as your login shell.

    chsh -s /bin/zsh

Install
-------

Clone onto your laptop:

    git clone git://github.com/croaky/dotfiles.git

Install:

    cd dotfiles
    ./install.sh

This will create symlinks for config files in your home directory.

You can safely run `./install.sh` multiple times to update.

What's in it?
-------------

[vim](http://www.vim.org/) configuration:

* [gocode](https://github.com/nsf/gocode), an autocompletion daemon for the Go
  programming language.
* Syntax highlighting for Go.

[git](http://git-scm.com/) configuration:

* `l` alias for tight, colored, log output.
* My name and email.

[zsh](http://zsh.sourceforge.net/FAQ/zshfaq01.html) configuration and aliases:

* `todo` to edit my todo file, located at `~/Dropbox/todo`.
* Load [rbenv](https://github.com/sstephenson/rbenv).
* Specify location of [Go workspace](http://golang.org/doc/code.html#GOPATH).
