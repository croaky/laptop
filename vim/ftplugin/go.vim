" $LAPTOP/bin/goimportslocal
let g:go_fmt_command = 'goimportslocal'
let g:go_rename_command = 'gopls'

" https://github.com/golang/tools/blob/master/gopls/doc/vim.md
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

" Lint
let b:ale_linters = ['gopls']

setlocal listchars=tab:\ \ ,trail:·,nbsp:·
setlocal noexpandtab

" Don't highlight tabs as extra whitespace
setlocal nolist

compiler go

nmap :A<CR> :GoAlternate
nmap <buffer> <Leader>r :!clear && go run %<CR>
nmap <buffer> <Leader>t :!clear && go test ./...<CR>
nmap <buffer> <Leader>s <Plug>(go-test-func) " Run test under cursor

" Syntax highlight additional tokens
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1
