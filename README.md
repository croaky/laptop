# Dotfiles

I use [thoughtbot/dotfiles][thoughtbot] and croaky/dotfiles
together using [the .local convention][dot-local].

[thoughtbot]: https://github.com/thoughtbot/dotfiles
[dot-local]: https://blog.statusok.com/combine-team-and-personal-dotfiles-with-rcm

## Requirements

Set zsh as my login shell.

```
chsh -s /bin/zsh
```

Install [rcm].

[rcm]: https://github.com/thoughtbot/rcm

```
brew tap thoughtbot/formulae
brew install rcm
```

## Install

Clone onto my laptop:

```
git clone git://github.com/croaky/dotfiles.git
```

Install:

```
env RCRC=$HOME/croaky/dotfiles/rcrc rcup
```

This will create symlinks for config files in my home directory.

I can safely run `rcup` multiple times to update.

## Vim config

* [ale] for linting on file save
* [neoformat] for automatically formatting on file save:
  JavaScript with [Prettier],
  Markdown with [Remark]
* [vim-colors-github] for GitHub color scheme
* [vim-easy-align] for [aligning Markdown tables][align]
* [vim-javascript] for JavaScript syntax highlighting
* [vim-jsx] for JSX syntax highlighting
* [vim-phoenix] for navigating Elixir Phoenix projects
* [words-to-avoid.vim] for highlighting weasel words in Markdown

[align]: https://blog.statusok.com/align-markdown-tables-with-vim
[Prettier]: https://github.com/prettier/prettier
[Remark]: https://github.com/wooorm/remark
[ale]: https://github.com/w0rp/ale
[neoformat]: https://github.com/sbdchd/neoformat
[vim-colors-github]: https://github.com/acarapetis/vim-colors-github
[vim-easy-align]: https://github.com/junegunn/vim-easy-align
[vim-javascript]: https://github.com/pangloss/vim-javascript
[vim-jsx]: https://github.com/mxw/vim-jsx
[vim-phoenix]: https://github.com/avdgaag/vim-phoenix
[words-to-avoid.vim]: https://github.com/nicholaides/words-to-avoid.vim

## Git config and aliases

* `l` alias for tight, colored, log output.
* My name and email.

## Z shell config and aliases

* `todo` to edit my plain text todo file, located in Dropbox
* `restart-postgres` alias to restart Homebrew'd Postgres
* `gpg` alias for `gpg2`
* `install-missing-ruby` alias to upgrade Homebrew'd `ruby-build` and install
  Ruby implicitly from `.ruby_version` file in current directory
* Add [Go workspace][go] to `PATH`
* Add [Yarn binaries][yarn] to `PATH`

[go]: http://golang.org/doc/code.html#GOPATH
[yarn]: https://yarnpkg.com/en/docs/install
