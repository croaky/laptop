-- Auto-fix
vim.b.ale_fixers = {'prettier'}
vim.g.ale_fix_on_save = 1

-- Lint
vim.b.ale_linters = {'prettier'}

-- Treat <li> and <p> tags like the block tags they are
vim.g.html_indent_tags = 'li\\|p'
