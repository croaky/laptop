" Auto-fix
let b:ale_fixers = ['prettier']
let g:ale_fix_on_save = 1

" Lint
let b:ale_linters = ['prettier']

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'
