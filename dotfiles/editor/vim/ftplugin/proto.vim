" go get github.com/ckaznocha/protoc-gen-lint
let g:ale_linters = {'proto': ['protoc-gen-lint']}
let g:ale_proto_protoc_gen_lint_options = '-I src'
