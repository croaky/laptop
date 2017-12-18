# Dotfiles

A script to set up an macOS laptop for web and mobile development.

It can be run multiple times on the same machine safely.
It installs, upgrades, or skips packages
based on what is already installed on the machine.

Tested on macOS Sierra (10.12).

## Install

Clone onto laptop:

```
git clone git@github.com:croaky/dotfiles.git
cd dotfiles
```

Review the script (avoid running scripts you haven't read!):

```sh
less mac
```

Execute the downloaded script:

```sh
sh mac 2>&1 | tee ~/laptop.log
```

Optionally, review the log:

```sh
less ~/laptop.log
```

This will install or update programs listed in `mac`
and then use [rcm]'s `rcup` command
to create symlinks of the config files in this repo
to the `~/` (`$HOME`) directory.

[rcm]: https://github.com/thoughtbot/rcm

The script is safe to run multiple times to update.

## What it sets up

macOS tools:

* [Homebrew] for managing operating system libraries.

[Homebrew]: http://brew.sh/

Programming languages, package managers, and configuration:

* [ASDF] for managing programming language versions
* Latest [Ruby] programming language version
* Latest [Go] programming language version
* [Expo XDE] for managing React Native development
  without XCode or Android Studio
* [Bundler] for managing Ruby libraries
* [Node.js] and [NPM], for running apps and installing JavaScript packages
* [Yarn] for managing JavaScript packages

[ASDF]: https://github.com/asdf-vm/asdf
[Bundler]: http://bundler.io/
[ImageMagick]: http://www.imagemagick.org/
[Node.js]: http://nodejs.org/
[NPM]: https://www.npmjs.org/
[Ruby]: https://www.ruby-lang.org/en/
[Go]: http://golang.org/
[Yarn]: https://yarnpkg.com/en/
[Expo XDE]: https://docs.expo.io/versions/v18.0.0/index.html

Databases:

* [Postgres] for storing relational data
* [Redis] for storing key-value data

[Postgres]: http://www.postgresql.org/
[Redis]: http://redis.io/

[Git](http://git-scm.com/) configuration and GitHub tools:

* [Hub] for interacting with the GitHub API
* `l`, `lt`, `la`, `lta` alias for tight, colored, log output.
  `t` means `time`, `a` means `author`.
* My name and email.
* Adds a `create-branch` alias to create feature branches.
* Adds a `delete-branch` alias to delete feature branches.
* Adds a `merge-branch` alias to merge feature branches into master.
* Adds an `up` alias to fetch and rebase `origin/master` into the feature
  branch. Use `git up -i` for interactive rebases.
* Adds `post-{checkout,commit,merge}` hooks to re-index your ctags.
* Adds `pre-commit` and `prepare-commit-msg` stubs that delegate to your local
  config.

[Hub]: http://hub.github.com/

[Ruby](https://www.ruby-lang.org/en/) configuration:

* Add trusted binstubs to the `PATH`.
* Load ASDF into the shell, adding shims onto our `PATH`.

Shell aliases and scripts:

* `b` for `bundle`.
* `g` with no arguments is `git status` and with arguments acts like `git`.
* `migrate` for `rake db:migrate && rake db:rollback && rake db:migrate`.
* `mcd` to make a directory and change into it.
* `replace foo bar **/*.rb` to find and replace within a given list of files.
* `tat` to attach to tmux session named the same as the current directory.
* `v` for `$VISUAL`.

Unix tools:

* [Exuberant Ctags] for indexing files for vim tab completion
* [Git] for version control
* [OpenSSL] for Transport Layer Security (TLS)
* [RCM] for managing company and personal dotfiles
* [The Silver Searcher] for finding things in files
* [Tmux] for saving project state and switching between projects
* [Watchman] for watching for filesystem events
* [Zsh] as the shell

[Exuberant Ctags]: http://ctags.sourceforge.net/
[Git]: https://git-scm.com/
[OpenSSL]: https://www.openssl.org/
[RCM]: https://github.com/thoughtbot/rcm
[The Silver Searcher]: https://github.com/ggreer/the_silver_searcher
[Tmux]: http://tmux.github.io/
[Watchman]: https://facebook.github.io/watchman/
[Zsh]: http://www.zsh.org/

[tmux](http://robots.thoughtbot.com/a-tmux-crash-course)
configuration:

* Improve color resolution.
* Remove administrative debris (session name, hostname, time) in status bar.
* Set prefix to `Ctrl+s`
* Soften status bar color from harsh green to light gray.

Heroku tools:

* [Heroku CLI] and [Parity] for interacting with the Heroku API

[Heroku CLI]: https://devcenter.heroku.com/articles/heroku-cli
[Parity]: https://github.com/thoughtbot/parity

Image tools:

* [ImageMagick] for cropping and resizing images

Vim config in `vimrc`:

* Map `<Leader>ct` to re-index [Exuberant Ctags]
* Set `<Leader>` to a single space.
* Switch between the last two files with space-space
* Syntax highlighting for Markdown, HTML, JavaScript, Ruby, Go, Elixir, more.
* Use [The Silver Searcher] instead of Grep

Vim plugins in `vimrc.plugins`:

* [ctrlp] for fuzzy file/buffer/tag finding
* [neoformat] for auto-formatting JavaScript files with [Prettier] on save
* [vim-colors-github] for GitHub color scheme
* [vim-easy-align] for [aligning Markdown tables][align]
* [vim-javascript] for JavaScript syntax highlighting
* [vim-jsx] for JSX syntax highlighting
* [vim-mkdir] to create non-existing directories before writing the buffer
* [vim-plug] to manage plugins
* [vim-rails] for navigation in Rails apps
* [vim-test] for running focused tests
* [words-to-avoid.vim] for highlighting weasel words in Markdown

[Prettier]: https://github.com/prettier/prettier
[align]: https://blog.statusok.com/align-markdown-tables-with-vim
[ctrlp]: https://github.com/kien/ctrlp.vim
[neoformat]: https://github.com/sbdchd/neoformat
[vim-colors-github]: https://github.com/acarapetis/vim-colors-github
[vim-easy-align]: https://github.com/junegunn/vim-easy-align
[vim-javascript]: https://github.com/pangloss/vim-javascript
[vim-jsx]: https://github.com/mxw/vim-jsx
[vim-mkdir]: https://github.com/pbrisbin/vim-mkdir
[vim-plug]: https://github.com/junegunn/vim-plug
[vim-rails]: https://github.com/tpope/vim-rails
[vim-test]: https://github.com/janko-m/vim-test
[words-to-avoid.vim]: https://github.com/nicholaides/words-to-avoid.vim

Z shell config and aliases:

* `todo` to edit my plain text todo file, located in Dropbox
* `restart-postgres` alias to restart Homebrew'd Postgres
* `gpg` alias for `gpg2`
* Add [Go workspace][gopath] to `PATH`
* Add [Yarn binaries][yarn] to `PATH`

[gopath]: http://golang.org/doc/code.html#GOPATH
[yarn]: https://yarnpkg.com/en/docs/install

## Zsh config

The `zsh/configs` directory has two special subdirectories:
`pre` for files that must be loaded first
`post` for files that must be loaded last.

Setting a key binding can happen in `zsh/configs/keys`:

```
# Grep anywhere with ^G
bindkey -s '^G' ' | grep '
```

Some changes, like `chpwd`, must happen in `zsh/configs/post/chpwd`:

```
# Show the entries in a directory whenever you cd in
function chpwd {
  ls
}
```

## Vim config

Similar to the Zsh config,
Vim automatically loads all files in the `vim/plugin` directory.
This does not have the same `pre` or `post` subdirectory support as Zsh.
