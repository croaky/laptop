-- Paths
vim.opt.runtimepath:prepend("~/.vim")
vim.opt.packpath = vim.opt.runtimepath:get()

-- Leader key
vim.g.mapleader = " "

-- General
vim.opt.cmdheight = 1
vim.opt.cursorline = false
vim.opt.cursorcolumn = false
vim.opt.diffopt:append("vertical")
vim.opt.expandtab = true
vim.opt.fillchars:append({ eob = " " }) -- Hide ~ end-of-file markers
vim.opt.history = 50
vim.opt.joinspaces = false -- Use one space, not two, after punctuation
vim.opt.laststatus = 2 -- Always display status line
vim.opt.list = true
vim.opt.listchars:append({ tab = "»·", trail = "·", nbsp = "·" })
vim.opt.modeline = false -- Disable as a security precaution
vim.opt.mouse = ""
vim.opt.number = false
vim.opt.shell = "/opt/homebrew/bin/zsh"
vim.opt.shiftround = true
vim.opt.shiftwidth = 2
vim.opt.shortmess:append("c")
vim.opt.showcmd = true -- Display incomplete commands
vim.opt.signcolumn = "no"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.tabstop = 2
vim.opt.textwidth = 80
vim.opt.timeoutlen = 300
vim.opt.updatetime = 300

-- Use Lazy for plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- Sensible defaults
	"tpope/vim-sensible",

	-- LSP Config
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },
	},

	-- Completion
	{
		"saghen/blink.cmp",
		-- use a release tag to download pre-built binaries
		version = "1.3.1",
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				preset = "default",
				["<Tab>"] = { "select_and_accept", "fallback" },
			},
			completion = { documentation = { auto_show = false } },
			sources = {
				default = { "lsp", "path", "buffer" },
			},
			cmdline = {
				keymap = {
					["<Tab>"] = { "show", "accept" },
					["<Up>"] = { "select_prev", "fallback" },
					["<Down>"] = { "select_next", "fallback" },
				},
				completion = { menu = { auto_show = true } },
			},
		},
		-- https://cmp.saghen.dev/configuration/fuzzy.html
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"RRethy/nvim-treesitter-endwise",
			"nvim-treesitter/playground",
		},
	},

	-- Fuzzy-finding :Rg, :Commits, :Files
	{ "junegunn/fzf", dir = "/opt/homebrew/opt/fzf" },
	{ "junegunn/fzf.vim" },

	-- :A, .projections.json
	{ "tpope/vim-projectionist" },

	-- :TestFile, :TestNearest
	{ "vim-test/vim-test" },

	-- Editable quickfix
	{ "gabrielpoca/replacer.nvim" },

	-- Filesystem, :Rename, :Git blame
	{ "pbrisbin/vim-mkdir" },
	{ "tpope/vim-eunuch" },
	{ "tpope/vim-fugitive" },

	-- Alignment, auto pairs, auto tags
	{ "alvan/vim-closetag" },
	{ "windwp/nvim-autopairs" },

	-- Formatting
	{ "stevearc/conform.nvim" },

	-- Frontend
	{ "leafgarland/typescript-vim" },
	{ "mxw/vim-jsx" },
	{ "pangloss/vim-javascript" },

	-- Backend
	{ "tpope/vim-rails" },
	{ "vim-ruby/vim-ruby" },

	opts_extend = { "sources.default" },
})

-- Helper functions
local function map(mode, lhs, rhs, opts)
	opts = vim.tbl_extend("keep", opts or {}, { noremap = true, silent = false })
	vim.keymap.set(mode, lhs, rhs, opts)
end

local function pipefail(cmd)
	return "zsh -c 'set -e; set -o pipefail; " .. cmd .. "'"
end

local function run_file(key, cmd_template, split_cmd)
	map("n", key, function()
		local cmd = cmd_template:gsub("%%", vim.fn.expand("%:p"))
		vim.cmd(split_cmd)
		vim.cmd("terminal " .. cmd)
	end, { buffer = 0 })
end

function _G.get_user()
	-- Try to get GitHub username
	local github_user = vim.fn.systemlist("git config --get github.user")[1] or ""
	github_user = github_user:gsub("%s+", "")
	if github_user ~= "" then
		return "[" .. github_user .. "] "
	end

	-- Fall back to Unix username
	local unix_user = os.getenv("USER") or os.getenv("USERNAME") or ""
	if unix_user:match("^%w+$") then
		return "[" .. unix_user .. "] "
	else
		return ""
	end
end

-- Netrw
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = ".DS_Store"

-- Quickfix
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		map("n", "<Leader>e", function()
			require("replacer").run()
		end, { buffer = 0 })
	end,
})

-- Fuzzy-find files
map("n", "<C-p>", ":Files<CR>")
vim.g.fzf_layout = { window = { width = 0.95, height = 0.9 } }

-- Search contents of files in project
map("n", "\\", ":Rg ", { nowait = true })

-- Search word under cursor
vim.opt.grepprg = "rg --vimgrep"
map("n", "K", ':silent grep! "\\b<C-R><C-W>\\b"<CR>:cw<CR>')

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

-- LSPs
local lspconfig = require("lspconfig")
local capabilities = require("blink.cmp").get_lsp_capabilities()
local on_attach = function(_, bufnr)
	map("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
	map("n", "gh", vim.lsp.buf.hover, { buffer = bufnr })
	map("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr })
	map("n", "gn", vim.lsp.buf.rename, { buffer = bufnr })
	map("n", "gr", vim.lsp.buf.references, { buffer = bufnr })
end

-- Terminal
vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true })

-- Formatting
require("conform").setup({
	format_on_save = {
		lsp_format = "fallback",
		timeout_ms = 1500, -- rubocop is slow
	},
	notify_on_error = true,
	notify_no_formatters = true,
	formatters_by_ft = {
		go = { "goimportslocal" }, -- $LAPTOP/bin/goimportslocal
		html = { "prettier" },
		javascript = { "prettier" }, -- prettier --parser html
		json = { "prettier" }, -- prettier --parser json
		lua = { "stylua" },
		markdown = { "prettier" }, -- prettier --parser markdown
		ruby = { "bundlerubocop" },
		scss = { "prettier" }, -- prettier --parser scss
		sh = { "shfmt" },
		sql = { "pg_format" },
		typescript = { "prettier" }, -- prettier --parser typescript
		typescriptreact = { "prettier" }, -- prettier --parser typescript
	},
	formatters = {
		bundlerubocop = {
			command = "bundle",
			args = { "exec", "rubocop", "--server", "-a", "-f", "quiet", "--stderr", "--stdin", "$FILENAME" },
		},
		goimportslocal = {
			command = "goimportslocal",
			args = { "-srcdir", "$DIRNAME" },
		},
		pg_format = {
			args = { "--function-case", "1", "--keyword-case", "2", "--spaces", "2", "--no-extra-line" },
		},
		shfmt = {
			args = { "--indent", "2" },
		},
	},
})

-- Env
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = ".env",
	command = "set filetype=text",
})

-- Bash
lspconfig.bashls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- Gitcommit
vim.api.nvim_create_autocmd("FileType", {
	pattern = "gitcommit",
	callback = function()
		vim.opt_local.textwidth = 72
		vim.opt_local.complete:append("kspell")
		vim.opt_local.spell = true
	end,
})

-- Go
lspconfig.gopls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		run_file("<Leader>r", "go run %", "split")

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
	end,
})

-- HTML
lspconfig.html.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "html",
	callback = function()
		-- Treat <li> and <p> tags like the block tags they are
		vim.g.html_indent_tags = "li\\|p"
	end,
})

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
vim.api.nvim_create_autocmd("FileType", {
	pattern = "lua",
	callback = function()
		-- Don't highlight tabs as extra whitespace
		vim.opt_local.list = false
	end,
})

-- Markdown
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		-- Align GitHub-flavored Markdown tables
		map("v", "<Leader>\\", ":EasyAlign*<Bar><Enter>", { buffer = 0 })

		-- Spell-checking
		vim.opt_local.complete:append("kspell")
		vim.opt_local.spell = true

		-- View hyperlinks like rendered output
		vim.opt_local.conceallevel = 0

		-- Add embed code fence block
		map("n", "<Leader>e", function()
			local lines = {
				"```embed",
				"",
				"```",
			}
			local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
			vim.api.nvim_buf_set_lines(0, row, row, false, lines)

			-- Move cursor to the middle line
			vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
		end, { buffer = 0 })

		-- Run through LLM
		run_file("<Leader>r", pipefail("(cat %; [ -f .llm.md ] && cat .llm.md) | mdembed | mods"), "vsplit")
		run_file("<Leader>c", pipefail("cat % | mdembed | mods -C"), "vsplit")
	end,
})

-- Ruby
lspconfig.ruby_lsp.setup({
	capabilities = capabilities,
	on_attach = on_attach,
	init_options = {
		formatter = "rubocop",
	},
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "ruby",
	callback = function()
		run_file("<Leader>r", "bundle exec ruby %", "split")

		map("n", "<Leader>i", function()
			local lines = {
				"    attr_reader :db",
				"",
				"    def initialize(db)",
				"      @db = db",
				"    end",
				"",
			}
			local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
			vim.api.nvim_buf_set_lines(0, row, row, false, lines)
		end, { buffer = 0 })
	end,
})

-- SQL
vim.api.nvim_create_autocmd("FileType", {
	pattern = "sql",
	callback = function()
		-- Map <Leader>r to run the current SQL file
		vim.api.nvim_buf_set_keymap(0, "n", "<Leader>r", "", {
			noremap = true,
			silent = true,
			callback = function()
				-- Get the full path of the current file
				local path = vim.fn.expand("%:p")

				-- Read the database name from the .db file
				local db_file = io.open(".db", "r")
				if not db_file then
					print("Cannot read .db file")
					return
				end
				local dbname = db_file:read("*l")
				db_file:close()

				-- Construct the psql command
				local cmd = 'psql -d "' .. dbname .. '" -f "' .. path .. '"'

				-- Capture the output of the psql command
				local output = vim.fn.systemlist(cmd)

				-- Check for command execution errors
				if output == nil then
					print("Error executing psql command")
					return
				end

				-- Open a new split window and set it up
				vim.cmd("new")
				local buf = vim.api.nvim_get_current_buf()

				-- Insert the output into the new buffer
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

				-- Set buffer options for a better experience
				vim.bo[buf].buftype = "nofile"
				vim.bo[buf].bufhidden = "wipe"
				vim.bo[buf].swapfile = false

				-- Move cursor to the top of the output buffer
				vim.cmd("normal! gg")
			end,
		})
	end,
})

-- TypeScript
lspconfig.ts_ls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
vim.g.markdown_fenced_languages = { "ts=typescript" }

-- Status line
vim.opt.statusline = "%{v:lua.get_user()}%f %h%m%r%=%-14.(%l,%c%V%) %P"

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
hi hamlClass             guifg=#9664c8

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
