" Auto-format on save. All file patterns to support Ruby shell scripts.
augroup fmt
  autocmd!
  autocmd BufWritePre * Neoformat rubocop
augroup END
