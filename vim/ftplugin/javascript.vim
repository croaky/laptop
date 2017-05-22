let g:javascript_plugin_flow = 1
let g:jsx_ext_required = 0

autocmd BufWritePre *.js Neoformat prettier
