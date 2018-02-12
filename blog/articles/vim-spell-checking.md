# Vim Spell Checking

There are times when we edit prose in Vim,
such as in a project `README` or Git commit message.
In those cases,
we can use Vim's spell-checking to help us avoid embarrassing mistakes.

## Switching on spell-checking

We can switch on spell checking with this command:

```
:setlocal spell
```

We can also specify the language:

```
:setlocal spell spelllang=en_us
```

## What does it look like

Here's a screenshot of what I see as I edit this blog post:

![''](images/vim-spell-check.png)

The highlighted words are considered misspellings.

## Spell check per filetype

It would be tedious to manually turn on spell-checking each time we need it.
Luckily, we can guess by convention that we'll want to spell-check certain files.

We automatically turn on spell-checking for Markdown files based on their file
extension with this line in our `~/.vimrc` via [thoughtbot/dotfiles][dotfiles]:

```
autocmd BufRead,BufNewFile *.md setlocal spell
```

[dotfiles]: https://github.com/thoughtbot/dotfiles/blob/master/vimrc

Another way to do it for certain filetypes is like this:

```
autocmd FileType gitcommit setlocal spell
```

## We get word completion for free

By turning on spell-checking in our `~/.vimrc`, we'll be turning on word
completion as well. The following command will let us press `CTRL-N` or
`CTRL-P` in insert-mode to complete the word we're typing!

```
set complete+=kspell
```

## Add words to the dictionary

We can add words like "RSpec" or "thoughtbot" to the `spellfile`
(a list of correctly-spelled words)
by cursoring over those words in a file and typing:

```
zg
```
