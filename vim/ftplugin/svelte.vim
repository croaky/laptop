let g:svelte_preprocessors = ['typescript', 'postcss']

" Auto-fix
let b:ale_fixers = ['prettier']
let g:ale_fix_on_save = 1
let g:ale_javascript_prettier_options = '--plugin-search-dir=.'

" Don't highlight tabs as extra whitespace
setlocal nolist
