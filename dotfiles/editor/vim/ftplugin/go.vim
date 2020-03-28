" $LAPTOP/bin/goimportslocal
let g:go_fmt_command = 'goimportslocal'
let g:go_rename_command = 'gopls'

" disable vim-go :GoDef shortcut, use coc.vim's gd instead
let g:go_def_mapping_enabled = 0

setlocal listchars=tab:\ \ ,trail:·,nbsp:·
setlocal noexpandtab

" Don't highlight tabs as extra whitespace
setlocal nolist

compiler go

nmap <buffer> <Leader>r <Plug>(go-run)       " Run current file
nmap <buffer> <Leader>t <Plug>(go-test)      " Run test suite
nmap <buffer> <Leader>s <Plug>(go-test-func) " Run test under cursor

" Syntax highlight additional tokens
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1

" Alias :GoAlternate to :A
autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
