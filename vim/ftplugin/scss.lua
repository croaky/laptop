vim.opt_local.iskeyword:append("-")

-- Auto-fix
vim.b.ale_fixers = {'prettier'}
vim.g.ale_fix_on_save = 1

-- Lint
vim.b.ale_linters = {'prettier'}
