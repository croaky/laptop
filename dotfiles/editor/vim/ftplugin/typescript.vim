let b:ale_fixers = ['prettier']
let b:ale_linters = ['tslint', 'tsserver']
let g:ale_fix_on_save = 1

nnoremap <buffer> <silent> gd :ALEGoToDefinition<CR>
