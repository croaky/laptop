" Fix and lint
let g:ale_fix_on_save = 1
let b:ale_fixers = ['crystal']
let b:ale_linters = ['crystal']

" Run current file
nmap <buffer> <Leader>r :terminal crystal %<CR>
nmap <buffer> <Leader>t :terminal KEMAL_ENV=test crystal spec %<CR>
