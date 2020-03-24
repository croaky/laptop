" TODO: try sorbet https://sorbet.org/
let b:ale_fixers = ['standardrb'] " 'rubocop'
let g:ale_fix_on_save = 1
let b:ale_linters = ['standardrb'] " 'rubocop'

" https://github.com/testdouble/standard/wiki/IDE:-vim
let g:ruby_indent_assignment_style = 'variable'

" Run current file
nmap <buffer> <Leader>r :!clear && bundle exec ruby %<CR>
