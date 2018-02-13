" Auto-format on save
augroup fmt
  autocmd!
  autocmd BufWritePre *.ts,*.tsx Neoformat prettier
augroup END

let g:ale_linters = {
\  'typescript': ['tslint', 'tsserver'],
\}
