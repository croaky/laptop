" Auto-fix
let b:ale_fixers = ['prettier'] " ['deno']
let g:ale_fix_on_save = 1

" Lint
let b:ale_linters = ['tsserver']

" Run current file w/ Deno
nmap <buffer> <Leader>r :!clear && deno run %<CR>
