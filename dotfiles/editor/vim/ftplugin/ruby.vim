" Auto-format on save. All file patterns to support Ruby shell scripts.
augroup fmt
  autocmd!
  autocmd BufWritePre * Neoformat rubocop
augroup END

" Run current file
nmap <Leader>r :!clear && bundle exec ruby %<CR>
