-- Set runtime path and packpath
vim.opt.runtimepath:prepend("~/.vim")
vim.opt.packpath = vim.opt.runtimepath:get()

-- Set leader key
vim.g.mapleader = " "

-- General settings
vim.opt.autoindent = true
vim.opt.backup = false
vim.opt.cmdheight = 2
vim.opt.complete:append("kspell")
vim.opt.diffopt:append("vertical")
vim.opt.expandtab = true
vim.opt.exrc = true -- Project-specific vimrc
vim.opt.fillchars:append({ eob = " " }) -- Hide ~ end-of-file markers
vim.opt.hidden = true -- Allow switching between buffers without saving
vim.opt.history = 50
vim.opt.incsearch = true
vim.opt.joinspaces = false -- Use one space, not two, after punctuation
vim.opt.laststatus = 2 -- Always display status line
vim.opt.list = true
vim.opt.listchars:append({ tab = "»·", trail = "·", nbsp = "·" })
vim.opt.modeline = false -- Disable modelines as a security precaution
vim.opt.mouse = ""
vim.opt.ruler = true -- Show cursor position all the time
vim.opt.shiftround = true
vim.opt.shiftwidth = 2
vim.opt.shortmess:append("c")
vim.opt.showcmd = true -- Display incomplete commands
vim.opt.signcolumn = "no"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.textwidth = 80
vim.opt.updatetime = 300
vim.opt.writebackup = false

-- Dependencies
vim.cmd([[packadd packer.nvim]])
require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	-- LSP
	use("neovim/nvim-lspconfig")

	-- Completion
	use("hrsh7th/cmp-nvim-lsp") -- complete with LSP
	use("hrsh7th/cmp-buffer") -- complete words from current buffer
	use("hrsh7th/cmp-path") -- complete file paths
	use("hrsh7th/cmp-cmdline") -- complete on command-line
	use("hrsh7th/nvim-cmp") -- core completion plugin framework

	-- Treesitter
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use("nvim-treesitter/playground")
	use("RRethy/nvim-treesitter-endwise")

	-- Fuzzy-finding :Ag, :Commits, :Files
	use("/opt/homebrew/opt/fzf")
	use("junegunn/fzf.vim")

	-- :help projectionist, .projections.json, :A
	use("tpope/vim-projectionist")

	-- :TestFile, :TestNearest
	use("vim-test/vim-test")

	-- Filesystem, :Rename, :Git blame
	use("pbrisbin/vim-mkdir")
	use("tpope/vim-eunuch")
	use("tpope/vim-fugitive")

	-- Alignment, auto pairs, auto tags
	use("alvan/vim-closetag")
	use("windwp/nvim-autopairs")

	-- Frontends
	use("leafgarland/typescript-vim")
	use("mxw/vim-jsx")
	use("pangloss/vim-javascript")

	-- Backends
	use({ "fatih/vim-go", run = ":GoInstallBinaries" })
	use("tpope/vim-rails")
	use("vim-ruby/vim-ruby")
end)

-- Helper functions
local function map(mode, lhs, rhs, opts)
	opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
	vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

local function buf_map(bufnr, mode, lhs, rhs, opts)
	opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
	vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
end

local function filetype_autocmd(ft, callback)
	vim.api.nvim_create_autocmd("FileType", {
		pattern = ft,
		callback = callback,
	})
end

local function format_on_save(cmd_template)
	vim.api.nvim_create_autocmd("BufWritePre", {
		buffer = 0,
		callback = function()
			local buffer_file = vim.fn.expand("%:p")
			-- Replace % placeholder in command template with actual file path
			local cmd = cmd_template:gsub("%%", buffer_file)

			-- Run async to prevent blocking main thread
			vim.fn.jobstart(cmd, {
				stdout_buffered = true,
				on_stdout = function(_, data)
					if not data then
						return
					end
					local formatted_content = table.concat(data, "\n")
					if #formatted_content == 0 then
						return
					end
					local pos = vim.api.nvim_win_get_cursor(0) -- Save current cursor position
					local lines = vim.split(formatted_content, "\n")

					-- Check if last line is empty. Remove it to prevent adding extra empty line
					if lines[#lines] == "" then
						table.remove(lines, #lines)
					end

					-- Update buffer with formatted content
					vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

					-- Adjust cursor position if necessary
					local new_line_count = vim.api.nvim_buf_line_count(0)
					if pos[1] > new_line_count then
						pos[1] = new_line_count
					end
					vim.api.nvim_win_set_cursor(0, pos)

					-- Write changes back to original file without triggering BufWritePre again
					vim.api.nvim_command("noautocmd write")
				end,
				on_stderr = function(_, data)
					if data then
						print(table.concat(data, "\n"))
					end
				end,
			})
		end,
	})
end

-- Netrw
vim.g.netrw_banner = 0 -- Remove banner
vim.g.netrw_list_hide = ".DS_Store" -- Hide system files

-- Fuzzy-find files
map("n", "<C-p>", ":Files<CR>")
vim.g.fzf_layout = { window = { width = 0.95, height = 0.9 } }

-- Search file contents
map("n", "\\", ":Ag<SPACE>")
vim.opt.grepprg = "ag --nogroup --nocolor"

-- Grep word under cursor
map("n", "K", ':grep! "\\b<C-R><C-W>\\b"<CR>:cw<CR>')

-- Switch between last two files
map("n", "<Leader><Leader>", "<C-^>")

-- Run tests
map("n", "<Leader>t", ":TestFile<CR>")
map("n", "<Leader>s", ":TestNearest<CR>")
vim.g.test_strategy = "neovim"
vim.g.test_neovim_start_normal = 1
vim.g.test_echo_command = 0

-- Move between windows
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")

-- Env
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = ".env",
	command = "set filetype=text",
})

-- Gitcommit
filetype_autocmd("gitcommit", function()
	vim.opt_local.textwidth = 72
	vim.opt_local.complete:append("kspell")
	vim.opt_local.spell = true
end)

-- LSPs
local lspconfig = require("lspconfig")
local on_attach = function(_, bufnr)
	buf_map(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
	buf_map(bufnr, "n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>")
	buf_map(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
	buf_map(bufnr, "n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")
	buf_map(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
	buf_map(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
end
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Go
lspconfig.gopls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})
filetype_autocmd("go", function()
	-- $LAPTOP/bin/goimportslocal
	vim.g.go_fmt_command = "goimportslocal"
	vim.g.go_rename_command = "gopls"

	-- https://github.com/golang/tools/blob/master/gopls/doc/vim.md
	vim.g.go_def_mode = "gopls"
	vim.g.go_info_mode = "gopls"

	-- Disable vim-go template
	vim.g.go_template_autocreate = 0

	vim.opt_local.listchars = { tab = "  ", trail = "·", nbsp = "·" }
	vim.opt_local.expandtab = false

	-- Don't highlight tabs as extra whitespace
	vim.opt_local.list = false

	vim.cmd("compiler go")

	buf_map(0, "n", ":A<CR>", ":GoAlternate<CR>")
	buf_map(0, "n", "<Leader>r", ":redraw!<CR>:!go run %<CR>")

	-- Syntax highlight additional tokens
	vim.g.go_highlight_fields = 1
	vim.g.go_highlight_functions = 1
	vim.g.go_highlight_methods = 1
	vim.g.go_highlight_operators = 1
	vim.g.go_highlight_structs = 1
end)

-- HTML
lspconfig.html.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})
filetype_autocmd("html", function()
	format_on_save("prettier --parser html %")

	-- Treat <li> and <p> tags like the block tags they are
	vim.g.html_indent_tags = "li\\|p"
end)

-- JSON
filetype_autocmd("json", function()
	format_on_save("prettier --parser json %")
end)

-- Lua
lspconfig.lua_ls.setup({
	cmd = { "lua-language-server" },
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		Lua = {
			runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
				},
			},
			telemetry = { enable = false },
		},
	},
})
filetype_autocmd("lua", function()
	format_on_save("stylua %")

	-- Don't highlight tabs as extra whitespace
	vim.opt_local.list = false
end)

-- Markdown
filetype_autocmd("markdown", function()
	format_on_save("prettier --parser markdown %")

	-- Align GitHub-flavored Markdown tables
	buf_map(0, "v", "<Leader>\\", ":EasyAlign*<Bar><Enter>")

	-- Spell-checking
	vim.opt_local.complete:append("kspell")
	vim.opt_local.spell = true

	-- View hyperlinks like rendered output
	vim.opt_local.conceallevel = 2
end)

-- Ruby
lspconfig.solargraph.setup({
	capabilities = capabilities,
	on_attach = on_attach,
	cmd = { "solargraph", "stdio" },
	filetypes = { "ruby" },
	root_dir = lspconfig.util.root_pattern("Gemfile", ".git"),
	settings = { solargraph = { diagnostics = false } },
})
filetype_autocmd("ruby", function()
	format_on_save(
		"cat % | bundle exec rubocop --config ./.rubocop.yml --stderr --stdin % --autocorrect --format quiet"
	)

	-- Run current file
	buf_map(0, "n", "<Leader>r", ":redraw!<CR>:!bundle exec ruby %<CR>")

	-- https://github.com/testdouble/standard/wiki/IDE:-vim
	vim.g.ruby_indent_assignment_style = "variable"
end)

-- SCSS
filetype_autocmd("scss", function()
	format_on_save("prettier --parser scss %")
end)

-- SQL
filetype_autocmd("sql", function()
	format_on_save("pg_format --function-case 1 --keyword-case 2 --spaces 2 --no-extra-line %")

	-- Run current file
	buf_map(0, "n", "<Leader>r", ":redraw!<CR>:!psql -d $(cat .db) -f % | less<CR>")

	-- Run current file with var(s)
	buf_map(0, "n", "<Leader>v", ":redraw!<CR>:!psql -d $(cat .db) -f % -v | less<SPACE>")
end)

-- TypeScript
lspconfig.tsserver.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	root_dir = lspconfig.util.root_pattern("package.json"),
})
vim.g.markdown_fenced_languages = { "ts=typescript" }
filetype_autocmd("typescript", function()
	format_on_save("prettier --parser typescript %")
end)

-- YAML
filetype_autocmd("yaml", function()
	format_on_save("prettier --parser yaml %")
end)

-- Completion
local cmp = require("cmp")
cmp.setup({
	mapping = cmp.mapping.preset.insert({
		["<TAB>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = false }),
	}),
	sources = cmp.config.sources({ { name = "nvim_lsp" } }, { { name = "buffer" } }),
})
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = { { name = "buffer" } },
})
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
})

-- Delegate most syntax highlighting decisions to Treesitter
-- https://neovim.io/doc/user/treesitter.html#treesitter-highlight
require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"bash",
		"css",
		"diff",
		"go",
		"html",
		"javascript",
		"json",
		"lua",
		"markdown",
		"ruby",
		"sql",
		"typescript",
		"vim",
		"yaml",
	},
	auto_install = true,
	highlight = { enable = true },
	incremental_selection = { enable = true },
	textobjects = { enable = true },
	endwise = { enable = true },
})
require("nvim-treesitter.configs").setup({
	playground = {
		enable = true,
		disable = {},
		updatetime = 25,
		persist_queries = false,
		keybindings = {
			toggle_query_editor = "o",
			toggle_hl_groups = "i",
			toggle_injected_languages = "t",
			toggle_anonymous_nodes = "a",
			toggle_language_display = "I",
			focus_language = "f",
			unfocus_language = "F",
			update = "R",
			goto_node = "<cr>",
			show_help = "?",
		},
	},
})

-- Custom syntax highlighting after Treesitter
vim.cmd([[hi clear]])

if vim.fn.exists("syntax_on") then
	vim.cmd([[syntax reset]])
end

-- See highlight group under cursor
-- :TSHighlightCapturesUnderCursor

-- Show all syntax groups
-- :so $VIMRUNTIME/syntax/hitest.vim

vim.cmd([[
" Sync w/ shell/kitty.conf background
hi Normal                               guibg=#191e2d
hi StatusLine            guifg=#191e2d

" White
hi Identifier            guifg=#ffffff
hi Keyword               guifg=#ffffff

" Light gray
hi Comment               guifg=#999999
hi Cursor                guifg=#999999
hi Ignore                guifg=#999999
hi LineNr                guifg=#999999
hi NonText               guifg=#999999
hi Operator              guifg=#999999
hi PmenuSel              guifg=#ffffff  guibg=#999999
hi PmenuThumb            guifg=#ffffff  guibg=#999999
hi Special               guifg=#999999
hi StatusLineNC          guifg=#999999
hi TabLine               guifg=#ffffff  guibg=#999999
hi VertSplit             guifg=#999999

" Yellow
hi DiagnosticWarn        guifg=#ffd080
hi Type                  guifg=#ffd080
hi RedrawDebugClear      guifg=#ffd080  guibg=#191e2d
hi Search                               guibg=#ffd080
hi String                guifg=#ffd080
hi WildMenu                             guibg=#d7005f

" Purple
hi @conditional          guifg=#9664c8
hi Directory             guifg=#9664c8
hi Function              guifg=#9664c8
hi PreProc               guifg=#9664c8

" Pink
hi @diff.minus           guifg=#d7005f
hi @symbol               guifg=#d7005f
hi @text.diff.delete     guifg=#d7005f
hi Boolean               guifg=#d7005f
hi ColorColumn                          guibg=#d7005f
hi Constant              guifg=#d7005f
hi DiagnosticError       guifg=#d7005f
hi DiffText                             guibg=#d7005f
hi Error                                guibg=#d7005f
hi ErrorMsg                             guibg=#d7005f
hi Number                guifg=#d7005f
hi NvimInternalError     guifg=#ffffff  guibg=#d7005f
hi Pmenu                                guibg=#d7005f
hi PreProc               guifg=#d7005f
hi RedrawDebugRecompose                 guibg=#d7005f
hi Statement             guifg=#d7005f
hi Title                 guifg=#d7005f
hi WarningMsg            guifg=#d7005f

" Green
hi @diff.plus            guifg=#64c88e
hi @text.diff.add        guifg=#64c88e
]])
