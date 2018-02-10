# Avoid Team-Wide Spelling Mistakes with Vim

If you and your teammates use Vim,
you can use these techniques for avoiding spelling mistakes.

## Machine-wide

Set up [Vim spell-checking and word completion][spelling]
on your machine's `~/.vimrc`:

[spelling]: https://blog.statusok.com/vim-spell-checking

```vim
autocmd BufRead,BufNewFile *.md set filetype=markdown

" Spell-check Markdown files
autocmd FileType markdown setlocal spell

" Spell-check Git messages
autocmd FileType gitcommit setlocal spell

" Set spellfile to location that is guaranteed to exist,
" can be symlinked to Dropbox or kept in Git
" and managed outside of thoughtbot/dotfiles using rcm.
set spellfile=$HOME/.vim-spell-en.utf-8.add

" Autocomplete with dictionary words when spell check is on
set complete+=kspell
```

thoughtbot shares these settings in our company-wide
[thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles/blob/master/vimrc).

## Project-specific

Each member of the team
can opt-in to a project-specific `.vimrc` file
by setting the following in their `~/.vimrc` file:

```vim
set exrc
```

Then, add the [project-specific `.vimrc` file][vimrc] to the Git repo:

[vimrc]: http://andrew.stwrt.ca/posts/project-specific-vimrc/

```vim
set spelllang=en_us
set spellfile=en.utf-8.add

" Disable unsafe commands.
" http://andrew.stwrt.ca/posts/project-specific-vimrc/
set secure
```

This is merged with the machine-wide settings.

Alternatively, we could include all necessary options
inside the project-specific file to provide coverage for
teammates who don't have machine-wide settings:

```vim
set spell
set spelllang=en_us
set spellfile=en.utf-8.add
set complete+=kspell

" Disable unsafe commands.
" http://andrew.stwrt.ca/posts/project-specific-vimrc/
set secure
```

## Spell-checking

Edit a project file
and Vim will highlight misspelled words.

Move to the next misspelled word with `]s`
(or move backwards with `[s`)
and type `zg` ("good word") to
add the word to the custom [spell file]:

[spell file]: http://vimdoc.sourceforge.net/htmldoc/spell.html#spell-mkspell

![](https://images.thoughtbot.com/opt-in-project-specific-vim-spell-checking-and-word-completion/R2zn7gHYTDa2ifrITAIn_project-specific-spelling.gif)

Add a phrase (words with whitespace between them) to the spell file
by selecting characters in Visual mode and then typing `zg`.

## Word suggestions

When the cursor is over a misspelled word,
get suggestions for the word with `z=`:

![](https://images.thoughtbot.com/opt-in-project-specific-vim-spell-checking-and-word-completion/Wr2e57HxSQyexSNrJc0f_word-suggestions.gif)

## Tab completion

The words in the spell file will show up in tab completion
because `.vimrc` is configured with `set complete+=kspell`:

![](https://images.thoughtbot.com/opt-in-project-specific-vim-spell-checking-and-word-completion/3Mfv6O7SICWkDEaxLCF8_tab-completion.gif)

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

## Conclusion

Add a `.vimrc` and shared spell file to your project
to build up a team-wide dictionary of shared terms,
help identify and correct misspellings,
and tab complete correctly-spelled words.
