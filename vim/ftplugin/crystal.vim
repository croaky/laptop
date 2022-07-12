" Fix and lint
let g:ale_fix_on_save = 1
let b:ale_fixers = ['crystal']
let b:ale_linters = ['crystal']

" Run current file
nmap <buffer> <Leader>r :!clear && crystal %<CR>
nmap <buffer> <Leader>t :!clear && KEMAL_ENV=test crystal spec %<CR>
