-- Auto-fix
vim.b.ale_fixers = {'prettier'}  -- 'deno'
vim.g.ale_fix_on_save = 1

-- Lint
vim.b.ale_linters = {'tsserver'}
