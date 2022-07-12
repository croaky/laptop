" Auto-fix
let b:ale_fixers = ['pgformatter'] " 'sqlfmt'
let g:ale_fix_on_save = 1
let b:ale_sql_pgformatter_options = '--function-case 1 --keyword-case 2 --spaces 2 --no-extra-line'

" Run current file
nmap <buffer> <Leader>r :!clear && psql -d $(cat .db) -f %<CR>

" Prepare SQL command with var(s)
nmap <buffer> <Leader>v :!clear && psql -d $(cat .db) -f % -v<SPACE>
