# Align Markdown Tables in Vim

You want a table in your GitHub document:

![Activation funnel](images/github-markdown-table.png)

[GitHub-Flavored Markdown][gh] supports formatting data as a table:

[gh]: https://help.github.com/articles/organizing-information-with-tables/

```
| Step                | Users  | Conversion | Obstacles            |
| ---                 | ---    | ---        | ---                  |
| Viewed Home Page    | 13,129 | 7.9%       | Messaging            |
| Viewed Sign Up Page | 1,044  | 20.6%      | Cost, credit card    |
| Signed Up           | 215    | 31.2%      | Credit card required |
| Entered Credit Card | 67     | 50.7%      | HTML, deployment     |
| Received Submission | 34     |            |                      |
```

Over time, as you edit this data in Vim,
keeping the Markdown table aligned could be painful,
but doesn't have to be.

Install [vim-easy-align] with a plugin manager such as [vim-plug].

[vim-easy-align]: https://github.com/junegunn/vim-easy-align
[vim-plug]: https://github.com/junegunn/vim-plug

```vim
Plug 'junegunn/vim-easy-align'
```

Set a `<Leader><Bslash>` mapping in `~/.vim/ftdetect/markdown.vim`:

```vim
" Align GitHub-Flavored Markdown tables
vmap <Leader><Bslash> :EasyAlign*<Bar><Enter>
```

The `<Bslash>` key is also the `|` key,
a mnemonic when looking at the `|`s of the table.

Here's how it looks:

![Visual select, leader, backslash](images/align-markdown-table-in-vim.gif)
