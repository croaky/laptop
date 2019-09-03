" $OK/bin/goimportslocal
let g:go_fmt_command = "goimportslocal"

setlocal listchars=tab:\ \ ,trail:·,nbsp:·
setlocal noexpandtab

" Don't highlight tabs as extra whitespace
setlocal nolist

compiler go

" Run current file
nmap <buffer> <Leader>r <Plug>(go-run)

" Run test suite
nmap <buffer> <Leader>t <Plug>(go-test)

" Run test for specific function under cursor
nmap <buffer> <Leader>s <Plug>(go-test-func)

" Rename the identifier under cursor
nmap <buffer> <Leader>re <Plug>(go-rename)

" Toggle test coverage
nmap <buffer> <Leader>c <Plug>(go-coverage-toggle)

" Open definition in a vertical split
nmap <buffer> <Leader>d <Plug>(go-def-vertical)

" List interfaces for the type under cursor
nmap <buffer> <Leader>i <Plug>(go-implements)

" Run :GoBuild or :GoTestCompile based on the file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#cmd#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>

" Use godef instead of guru
let g:go_def_mode = 'godef'

" Syntax highlight additional tokens
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1

" Alias :GoAlternate to :A
autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
