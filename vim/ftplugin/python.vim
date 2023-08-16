" Auto-fix
let g:ale_fix_on_save = 1

let b:ale_fixers = ['ruff']
let b:ale_linters = ['ruff']

" Run current file
nmap <buffer> <Leader>r :redraw!<CR>:!python3 %<CR>
