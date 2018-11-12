# Spell Check in Vim

Avoid spelling mistakes
when editing prose
in Markdown files
and Git commit messages.

## Configure

In `~/.vimrc`:

```vim
" Disable spelling by default, enable per-filetype
autocmd BufRead setlocal nospell
```

In `~/.vim/ftplugin/{gitcommit,markdown}.vim`:

[spelling]: vim-spell-checking

```vim
setlocal complete+=kspell
setlocal spell
```

## See highlighted misspellings

When I edit a Markdown file
or Git commit with `git commit -v`,
Vim will highlight misspelled words.
Move to the next misspelled word with `]s`
or move backwards with `[s`:

![](images/project-specific-spelling.gif)

## Add words to the dictionary

When the cursor is over a misspelled word,
type `zg` ("good word") to
add the word to the [spell file].
By default,
the spell file is located at
`~/.vim/spell/en.utf-8.add`.

[spell file]: http://vimdoc.sourceforge.net/htmldoc/spell.html#spell-mkspell

## Word suggestions

When the cursor is over a misspelled word,
get suggestions for the word with `z=`:

![](images/word-suggestions.gif)

## Tab completion

The words in the spell file will show up in tab completion:

![](images/tab-completion.gif)
