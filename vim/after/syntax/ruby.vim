" <<~SQL heredocs
let s:previous_syntax = b:current_syntax
unlet b:current_syntax
syntax include @SQL syntax/sql.vim
syntax region rubyHeredocSQL matchgroup=Statement start=+<<\~\z(SQL\)+ end=+\s\+\z1$+ contains=@SQL,rubyInterpolation
let b:current_syntax = s:previous_syntax
