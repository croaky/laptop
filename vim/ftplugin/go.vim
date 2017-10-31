let g:go_fmt_command = "goimports"
let g:go_fmt_options = {
      \ "goimports": "-local chain",
      \ }

setlocal listchars=tab:\ \ ,trail:·,nbsp:·
setlocal noexpandtab

compiler go

" Run current file
nmap <Leader>r <Plug>(go-run)

" Run test suite
nmap <Leader>t <Plug>(go-test)

" Run test for specific function under cursor
nmap <Leader>s <Plug>(go-test-func)

" Rename the identifier under cursor
nmap <Leader>re <Plug>(go-rename)

" Toggle test coverage
nmap <Leader>c <Plug>(go-coverage-toggle)

" Open definition in a vertical split
nmap <Leader>d <Plug>(go-def-vertical)

" List interfaces for the type under cursor
nmap <Leader>i <Plug>(go-implements)

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

" Syntax highlight additional tokens
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1

" Alias :GoAlternate to :A
autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
