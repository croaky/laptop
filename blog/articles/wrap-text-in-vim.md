# Wrap Text in Vim

You have an existing block of text or code in Vim.
You want to re-format it to wrap to 80 characters.

```
:set textwidth=80
```

Select the lines of text you want to re-format:

```
v
```

Reformat it:

```
gq
```

Learn more:

```
:h gq
```

If want the 80 character setting to apply automatically
for file types like Markdown,
add this to your `vimrc`:

```
au BufRead,BufNewFile *.md setlocal textwidth=80
```
