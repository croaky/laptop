autocmd BufRead,BufNewFile *.md,*.md.erb setfiletype markdown

" Align GitHub-flavored Markdown tables
vmap <Leader><Bslash> :EasyAlign*<Bar><Enter>
