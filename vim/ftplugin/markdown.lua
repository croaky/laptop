-- Align GitHub-flavored Markdown tables
vim.api.nvim_buf_set_keymap(0, 'v', '<Leader>\\', ':EasyAlign*<Bar><Enter>', { noremap = true, silent = true })

-- Spell-checking
vim.opt_local.complete:append("kspell")
vim.opt_local.spell = true

-- View hyperlinks like rendered output
vim.opt_local.conceallevel = 2
