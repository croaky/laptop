" Auto-format on save
augroup fmt
  autocmd!
  autocmd BufWritePre *.js,*.jsx Neoformat prettier
augroup END

let g:javascript_plugin_flow = 1
let g:jsx_ext_required = 0
