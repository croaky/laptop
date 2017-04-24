croaky dotfiles
===============

I use [thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles) and
croaky/dotfiles together using [the `*.local` convention][dot-local].

[dot-local]: http://robots.thoughtbot.com/manage-team-and-personal-dotfiles-together-with-rcm

Requirements
------------

Set zsh as my login shell.

    chsh -s /bin/zsh

Install [rcm](https://github.com/mike-burns/rcm).

    brew tap thoughtbot/formulae
    brew install rcm

Install
-------

Clone onto my laptop:

    git clone git://github.com/croaky/dotfiles.git

Install:

    env RCRC=$HOME/croaky/dotfiles/rcrc rcup

This will create symlinks for config files in my home directory.

I can safely run `rcup` multiple times to update.

What's in it?
-------------

[vim](http://www.vim.org/) configuration:

* [GitHub color scheme](https://github.com/croaky/vim-colors-github)
* [YouCompleteMe](https://github.com/Valloric/YouCompleteMe) for
  tab completion.
* [Emmet.vim](https://github.com/mattn/emmet-vim) for expanding CSS selectors
  into HTML when writing markup
* [words-to-avoid](https://github.com/nicholaides/words-to-avoid.vim) for
  highlighting weasel words in my Markdown writing.

[git](http://git-scm.com/) configuration:

* `l` alias for tight, colored, log output.
* My name and email.

[zsh](http://zsh.sourceforge.net/FAQ/zshfaq01.html) configuration and aliases:

* `todo` to edit my plain text todo file, located in Dropbox.
* `restart-postgres` alias to restart Homebrew'd Postgres.
* `gpg` alias for `gpg2`.
* `install-missing-ruby` alias to upgrade Homebrew'd `ruby-build` and install
  Ruby implicitly from `.ruby_version` file in current directory.
* Add [Go workspace][go] to `PATH`.
* Add [Node modules][nvm] to `PATH`.

[go]: http://golang.org/doc/code.html#GOPATH
[nvm]: https://github.com/creationix/nvm#manual-install
