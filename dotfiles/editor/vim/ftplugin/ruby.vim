let b:ale_fixers = ['rubocop']
let b:ale_linters = ['rubocop']
let g:ale_fix_on_save = 1

" Run current file
nmap <buffer> <Leader>r :!clear && bundle exec ruby %<CR>
