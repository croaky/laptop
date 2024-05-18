-- $LAPTOP/bin/goimportslocal
vim.g.go_fmt_command = 'goimportslocal'
vim.g.go_rename_command = 'gopls'

-- https://github.com/golang/tools/blob/master/gopls/doc/vim.md
vim.g.go_def_mode = 'gopls'
vim.g.go_info_mode = 'gopls'

-- Disable vim-go template
vim.g.go_template_autocreate = 0

-- Lint
vim.b.ale_linters = {'gopls'}

vim.opt_local.listchars = { tab = "  ", trail = "·", nbsp = "·" }
vim.opt_local.expandtab = false

-- Don't highlight tabs as extra whitespace
vim.opt_local.list = false

vim.cmd("compiler go")

vim.api.nvim_buf_set_keymap(0, 'n', ':A<CR>', ':GoAlternate<CR>', { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, 'n', '<Leader>r', ':redraw!<CR>:!go run %<CR>', { noremap = true, silent = true })

-- Syntax highlight additional tokens
vim.g.go_highlight_fields = 1
vim.g.go_highlight_functions = 1
vim.g.go_highlight_methods = 1
vim.g.go_highlight_operators = 1
vim.g.go_highlight_structs = 1
