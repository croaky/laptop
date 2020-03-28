" TODO: try sorbet https://sorbet.org/

" Auto-fix w/ standardrb?
" TODO: add coc.vim config

" Lint w/ standardrb?
" TODO: add coc.vim config

" https://github.com/testdouble/standard/wiki/IDE:-vim
let g:ruby_indent_assignment_style = 'variable'

" Run current file
nmap <buffer> <Leader>r :!clear && bundle exec ruby %<CR>
