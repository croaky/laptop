# Dotfiles

A script to set up an macOS laptop for web and mobile development.

It can be run multiple times on the same machine safely.
It installs, upgrades, or skips packages
based on what is already installed on the machine.

Tested on macOS Sierra (10.12).

## Install

Clone onto my laptop:

```
git clone git@github.com:croaky/dotfiles.git
cd dotfiles
```

Execute the script:

```sh
sh mac 2>&1 | tee ~/laptop.log
```

This will create symlinks for config files in my home directory.
I can safely run it multiple times to update.

Read through `~/laptop.log` to debug.

## What it sets up

macOS tools:

* [Homebrew] for managing operating system libraries.

[Homebrew]: http://brew.sh/

Unix tools:

* [Exuberant Ctags] for indexing files for vim tab completion
* [Git] for version control
* [OpenSSL] for Transport Layer Security (TLS)
* [RCM] for managing company and personal dotfiles
* [The Silver Searcher] for finding things in files
* [Tmux] for saving project state and switching between projects
* [Watchman] for watching for filesystem events
* [Zsh] as your shell

[Exuberant Ctags]: http://ctags.sourceforge.net/
[Git]: https://git-scm.com/
[OpenSSL]: https://www.openssl.org/
[RCM]: https://github.com/thoughtbot/rcm
[The Silver Searcher]: https://github.com/ggreer/the_silver_searcher
[Tmux]: http://tmux.github.io/
[Watchman]: https://facebook.github.io/watchman/
[Zsh]: http://www.zsh.org/

Heroku tools:

* [Heroku Toolbelt] and [Parity] for interacting with the Heroku API

[Heroku Toolbelt]: https://toolbelt.heroku.com/
[Parity]: https://github.com/thoughtbot/parity

GitHub tools:

* [Hub] for interacting with the GitHub API

[Hub]: http://hub.github.com/

Image tools:

* [ImageMagick] for cropping and resizing images

Testing tools:

* [Qt 5] for headless JavaScript testing via [Capybara Webkit]

[Qt 5]: http://qt-project.org/
[Capybara Webkit]: https://github.com/thoughtbot/capybara-webkit

Programming languages, package managers, and configuration:

* [Bundler] for managing Ruby libraries
* [Node.js] and [NPM], for running apps and installing JavaScript packages
* [Rbenv] for managing versions of Ruby
* [Ruby Build] for installing Rubies
* [Ruby] stable for writing general-purpose code
* [Yarn] for managing JavaScript packages

[Bundler]: http://bundler.io/
[ImageMagick]: http://www.imagemagick.org/
[Node.js]: http://nodejs.org/
[NPM]: https://www.npmjs.org/
[Rbenv]: https://github.com/sstephenson/rbenv
[Ruby Build]: https://github.com/sstephenson/ruby-build
[Ruby]: https://www.ruby-lang.org/en/
[Yarn]: https://yarnpkg.com/en/

Databases:

* [Postgres] for storing relational data
* [Redis] for storing key-value data

[Postgres]: http://www.postgresql.org/
[Redis]: http://redis.io/

Vim config:

* [ale] for linting on file save
* [neoformat] for automatically formatting on file save:
  JavaScript with [Prettier]
* [vim-colors-github] for GitHub color scheme
* [vim-easy-align] for [aligning Markdown tables][align]
* [vim-javascript] for JavaScript syntax highlighting
* [vim-jsx] for JSX syntax highlighting
* [vim-phoenix] for navigating Elixir Phoenix projects
* [words-to-avoid.vim] for highlighting weasel words in Markdown

[align]: https://blog.statusok.com/align-markdown-tables-with-vim
[Prettier]: https://github.com/prettier/prettier
[ale]: https://github.com/w0rp/ale
[neoformat]: https://github.com/sbdchd/neoformat
[vim-colors-github]: https://github.com/acarapetis/vim-colors-github
[vim-easy-align]: https://github.com/junegunn/vim-easy-align
[vim-javascript]: https://github.com/pangloss/vim-javascript
[vim-jsx]: https://github.com/mxw/vim-jsx
[vim-phoenix]: https://github.com/avdgaag/vim-phoenix
[words-to-avoid.vim]: https://github.com/nicholaides/words-to-avoid.vim

Git config and aliases:

* `l` alias for tight, colored, log output.
* My name and email.

Z shell config and aliases:

* `todo` to edit my plain text todo file, located in Dropbox
* `restart-postgres` alias to restart Homebrew'd Postgres
* `gpg` alias for `gpg2`
* `install-missing-ruby` alias to upgrade Homebrew'd `ruby-build` and install
  Ruby implicitly from `.ruby_version` file in current directory
* Add [Go workspace][go] to `PATH`
* Add [Yarn binaries][yarn] to `PATH`

[go]: http://golang.org/doc/code.html#GOPATH
[yarn]: https://yarnpkg.com/en/docs/install
