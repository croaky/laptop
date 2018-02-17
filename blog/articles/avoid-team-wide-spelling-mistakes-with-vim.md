# Avoid Team-Wide Spelling Mistakes with Vim

If you and your teammates use Vim,
these techniques can help avoid spelling mistakes.

## Machine-wide

Set up [Vim spell-checking and word completion][spelling]
on your machine's `~/.vim/ftplugin/gitcommit.vim`:

[spelling]: vim-spell-checking

```vim
setlocal complete+=kspell
setlocal spell
setlocal spellfile=$HOME/.vim-spell-en.utf-8.add " any dir outside project repo
```

## Project-specific

Each member of the team
can opt-in to a project-specific `.vimrc` file
by setting the following in their `~/.vimrc` file:

```vim
set exrc
```

Then, add the project-specific `.vimrc` file to the Git repo:

```vim
" http://andrew.stwrt.ca/posts/project-specific-vimrc/
set secure
set spellfile=en.utf-8.add
set spelllang=en_us
```

This is merged with the machine-wide settings.

## Spell-checking

When reviewing a Git commit in Vim with `git commit -v`,
Vim will highlight misspelled words.

Move to the next misspelled word with `]s`
(or move backwards with `[s`)
and type `zg` ("good word") to
add the word to the custom [spell file]:

[spell file]: http://vimdoc.sourceforge.net/htmldoc/spell.html#spell-mkspell

![](images/project-specific-spelling.gif)

Add a phrase (words with whitespace between them) to the spell file
by selecting characters in Visual mode and then typing `zg`.

## Word suggestions

When the cursor is over a misspelled word,
get suggestions for the word with `z=`:

![](images/word-suggestions.gif)

## Tab completion

The words in the spell file will show up in tab completion
because `.vimrc` is configured with `set complete+=kspell`:

![](images/tab-completion.gif)

## Shared spell file

Add the plain-text spell file, `en.utf-8.add`,
to version control in the project.

Vim uses a binary version,
`en.utf-8.add.spl`,
as a data structure to improve performance.
Ignore the binary version in `.gitignore`
because it will be automatically updated and reloaded when words
are added with `zg`:

```
en.utf-8.add.spl
```

The project-specific `en.utf-8.add` might look something like this:

```
RSS
SEO
Trello
URL
YAML
backticks
blog
iOS
repo
stylesheet
thoughtbot
vimrc
```

If you edit the file manually,
the binary version will not be updated and reloaded automatically.
In that case, run:

```
:edit <spell file>
(make changes to the spell file)
:mkspell! %
```
