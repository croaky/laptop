-- Auto-fix
vim.g.ale_fix_on_save = 1

-- Default to bundled rubocop
vim.g.ale_ruby_rubocop_executable = 'bundle'
vim.b.ale_fixers = {'rubocop'}
vim.b.ale_linters = {'rubocop'}

-- https://github.com/testdouble/standard/wiki/IDE:-vim
vim.g.ruby_indent_assignment_style = 'variable'

-- Run current file
vim.api.nvim_buf_set_keymap(0, 'n', '<Leader>r', ':redraw!<CR>:!bundle exec ruby %<CR>', { noremap = true, silent = true })
