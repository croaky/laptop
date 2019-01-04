let b:ale_fixers = ['prettier']
let b:ale_linters = ['tsserver']
let g:ale_linters_ignore = { 'typescript': ['tslint'] }
let g:ale_fix_on_save = 1

nnoremap <buffer> <silent> fr :ALEFindReferences<CR>
nnoremap <buffer> <silent> gd :ALEGoToDefinition<CR>
