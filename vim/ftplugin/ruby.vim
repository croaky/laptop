" Disable ALE for Sorbet type definition files
let g:ale_pattern_options = { '.*\.rbi$': {'ale_enabled': 0} }

" Auto-fix
let g:ale_fix_on_save = 1

" Default to bundled rubocop
let g:ale_ruby_rubocop_executable = 'bundle'
let b:ale_fixers = ['rubocop']
let b:ale_linters = ['rubocop']

" https://github.com/testdouble/standard/wiki/IDE:-vim
let g:ruby_indent_assignment_style = 'variable'

" Run current file
nmap <buffer> <Leader>r :!clear && bundle exec ruby %<CR>
