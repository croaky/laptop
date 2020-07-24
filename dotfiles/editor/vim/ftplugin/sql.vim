" Auto-fix
let b:ale_fixers = ['sqlfmt']
let g:ale_fix_on_save = 1

" Run current file
nmap <buffer> <Leader>r :!clear && psql -d $(cat .db) -f %<CR>
