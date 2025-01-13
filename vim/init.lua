-- Paths
vim.opt.runtimepath:prepend("~/.vim")
vim.opt.packpath = vim.opt.runtimepath:get()

-- Leader key
vim.g.mapleader = " "

-- General
vim.opt.autoindent = true
vim.opt.backup = false
vim.opt.cmdheight = 2
vim.opt.complete:append("kspell")
vim.opt.cursorline = false
vim.opt.cursorcolumn = false
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
vim.opt.number = false
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

-- Packages
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
	use({ "junegunn/fzf", dir = "/opt/homebrew/opt/fzf" })
	use("junegunn/fzf.vim")

	-- :A, .projections.json
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

	-- Frontend
	use("leafgarland/typescript-vim")
	use("mxw/vim-jsx")
	use("pangloss/vim-javascript")

	-- Backend
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

local function run_file(cmd_template)
	local cmd = cmd_template:gsub("%%", vim.fn.expand("%:p"))
	buf_map(0, "n", "<Leader>r", string.format(":redraw!<CR>:!%s<CR>", cmd))
end

local function format_on_save(cmd_template)
	vim.api.nvim_create_autocmd("BufWritePre", {
		buffer = 0,
		callback = function()
			local cmd = cmd_template:gsub("%%", vim.fn.expand("%:p"))
			local buf = vim.api.nvim_get_current_buf()

			vim.fn.jobstart(cmd, {
				stdout_buffered = true,
				on_stdout = function(_, data)
					if not data then
						return
					end

					local fmt = table.concat(data, "\n")
					if #fmt == 0 then
						return
					end

					local pos = vim.api.nvim_win_get_cursor(0)

					local lines = vim.split(fmt, "\n")
					if lines[#lines] == "" then
						table.remove(lines, #lines)
					end

					vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

					local line_count = vim.api.nvim_buf_line_count(buf)
					if pos[1] > line_count then
						pos[1] = line_count
					end

					vim.api.nvim_win_set_cursor(0, pos)

					vim.api.nvim_buf_call(buf, function()
						vim.cmd("noautocmd write")
					end)
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

-- Tmux
function _G.tmux_user_or_unix_user_from_env_vars()
	if vim.env.TMUX ~= nil then
		local tmux_user = vim.fn.getenv("TMUX_USER")
		if tmux_user and tmux_user:match("^%w+$") then
			return "[" .. tmux_user .. "] "
		end
	end

	local unix_user = os.getenv("USER") or os.getenv("USERNAME")
	if unix_user and unix_user:match("^%w+$") then
		return "[" .. unix_user .. "] "
	end

	return ""
end

-- Netrw
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = ".DS_Store"

-- Fuzzy-find files
map("n", "<C-p>", ":Files<CR>")
vim.g.fzf_layout = { window = { width = 0.95, height = 0.9 } }

-- Search file contents
vim.api.nvim_set_keymap("n", "\\", ":Ag<SPACE>", { noremap = true })
vim.opt.grepprg = "ag --nogroup --nocolor"

-- Grep word under cursor
map("n", "K", ':grep! "\\b<C-R><C-W>\\b"<CR>:cw<CR>')

-- Switch between last two files
map("n", "<Leader><Leader>", "<C-^>")

-- Run tests
map("n", "<Leader>t", ":TestFile<CR>")
map("n", "<Leader>s", ":TestNearest<CR>")
vim.g["test#strategy"] = "neovim"
vim.g["test#neovim#start_normal"] = 1
vim.g["test#echo_command"] = 0

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
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
local on_attach = function(_, bufnr)
	buf_map(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
	buf_map(bufnr, "n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>")
	buf_map(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
	buf_map(bufnr, "n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")
	buf_map(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
end

-- Go
lspconfig.gopls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})
filetype_autocmd("go", function()
	run_file("go run %")

	-- $LAPTOP/bin/goimportslocal
	format_on_save("goimportslocal %")

	vim.opt_local.listchars = { tab = "  ", trail = "·", nbsp = "·" }
	vim.opt_local.expandtab = false

	-- Don't highlight tabs as extra whitespace
	vim.opt_local.list = false

	--- :A to toggle between test file and Go file
	local function go_alternate()
		local curf = vim.api.nvim_buf_get_name(0)
		local altf

		if curf:match("_test%.go$") then
			altf = curf:gsub("_test%.go$", ".go")
		else
			altf = curf:gsub("%.go$", "_test.go")
		end

		if vim.fn.filereadable(altf) == 1 then
			vim.cmd("edit " .. altf)
		end
	end

	vim.api.nvim_create_user_command("A", go_alternate, {})
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

-- JavaScript
filetype_autocmd("javascript", function()
	format_on_save("prettier %")
end)

-- JSON
filetype_autocmd("json", function()
	format_on_save("prettier --parser json %")
end)

-- Lua
lspconfig.lua_ls.setup({
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
	settings = { solargraph = { diagnostics = false } },
})
filetype_autocmd("ruby", function()
	run_file("bundle exec ruby %")
	format_on_save("cat % | bundle exec rubocop --stderr --stdin % --autocorrect --format quiet")

	-- https://github.com/testdouble/standard/wiki/IDE:-vim
	vim.g.ruby_indent_assignment_style = "variable"
end)

-- SCSS
filetype_autocmd("scss", function()
	format_on_save("prettier --parser scss %")
end)

-- SQL
filetype_autocmd("sql", function()
	run_file("psql -d $(cat .db) -f % | less")
	format_on_save("pg_format --function-case 1 --keyword-case 2 --spaces 2 --no-extra-line %")
end)

-- TypeScript
lspconfig.ts_ls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
vim.g.markdown_fenced_languages = { "ts=typescript" }
filetype_autocmd("typescript", function()
	format_on_save("prettier --parser typescript %")
end)
filetype_autocmd("typescriptreact", function()
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
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "buffer" },
	}),
})

-- Status line
vim.opt.statusline = "%{v:lua.tmux_user_or_unix_user_from_env_vars()}%f %h%m%r%=%-14.(%l,%c%V%) %P"

-- Treesitter
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

	-- Delegate most syntax highlighting to Treesitter
	-- https://neovim.io/doc/user/treesitter.html#treesitter-highlight
	highlight = { enable = true },

	incremental_selection = { enable = true },
	textobjects = { enable = true },
	endwise = { enable = true },
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
-- :TSHighlightCapturesUnderCursor
-- :so $VIMRUNTIME/syntax/hitest.vim
vim.cmd([[hi clear]])

if vim.fn.exists("syntax_on") then
	vim.cmd([[syntax reset]])
end

vim.cmd([[
hi Normal                               guibg=#191e2d " Sync w/ shell/ghostty
hi StatusLine            guifg=#191e2d

" White
hi @attribute            guifg=#ffffff
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
hi RedrawDebugClear      guifg=#ffd080  guibg=#191e2d
hi Search                               guibg=#ffd080
hi String                guifg=#ffd080
hi Type                  guifg=#ffd080
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
