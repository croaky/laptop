-- Auto-fix
vim.g.ale_fix_on_save = 1

-- Set ALE fixers and linters
vim.b.ale_fixers = {'stylua'}
vim.b.ale_linters = {'lua-language-server'}

-- Run current file
vim.api.nvim_buf_set_keymap(0, 'n', '<Leader>r', ':redraw!<CR>:!lua %<CR>', { noremap = true, silent = true })
