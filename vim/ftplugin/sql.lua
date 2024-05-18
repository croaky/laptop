-- Auto-fix
vim.b.ale_fixers = {'pgformatter'}
vim.g.ale_fix_on_save = 1
vim.b.ale_sql_pgformatter_options = '--function-case 1 --keyword-case 2 --spaces 2 --no-extra-line'

-- Run current file
vim.api.nvim_buf_set_keymap(0, 'n', '<Leader>r', ':redraw!<CR>:!psql -d $(cat .db) -f % | less<CR>', { noremap = true, silent = true })

-- Prepare SQL command with var(s)
vim.api.nvim_buf_set_keymap(0, 'n', '<Leader>v', ':redraw!<CR>:!psql -d $(cat .db) -f % -v | less<SPACE>', { noremap = true, silent = true })
