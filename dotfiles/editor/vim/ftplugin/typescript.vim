" Auto-fix
let b:ale_fixers = {'typescript': ['deno']}
let g:ale_fix_on_save = 1 " run deno fmt when saving a buffer

" Lint
let b:ale_linters = ['tsserver']

" Run current file
nmap <buffer> <Leader>r :!clear && deno run %<CR>
