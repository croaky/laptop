" TODO: try sorbet https://sorbet.org/

" Auto-fix
let g:ale_fix_on_save = 1

" Default to standardrb
let b:ale_fixers = ['standardrb']
let b:ale_linters = ['standardrb']

" Fallback to rubocop
if filereadable('Gemfile.lock') && !len(matchstr(readfile(expand('Gemfile.lock')), 'standard'))
  let b:ale_fixers = ['rubocop']
  let b:ale_linters = ['rubocop']
endif

" https://github.com/testdouble/standard/wiki/IDE:-vim
let g:ruby_indent_assignment_style = 'variable'

" Run current file
nmap <buffer> <Leader>r :!clear && bundle exec ruby %<CR>
