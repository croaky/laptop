-- Set runtime path and packpath
vim.opt.runtimepath:prepend("~/.vim")
vim.opt.runtimepath:append("~/.vim/after")
vim.opt.packpath = vim.opt.runtimepath:get()

-- Set leader key
vim.g.mapleader = " "

-- General settings
vim.opt.autoindent = true
vim.opt.cmdheight = 2
vim.opt.complete:append("kspell")
vim.opt.diffopt:append("vertical")
vim.opt.expandtab = true
vim.opt.exrc = true  -- Project-specific vimrc
vim.opt.fillchars:append({ eob = " " })  -- Hide ~ end-of-file markers
vim.opt.hidden = true  -- Allow switching between buffers without saving
vim.opt.history = 50
vim.opt.incsearch = true
vim.opt.laststatus = 2  -- Always display status line
vim.opt.list = true
vim.opt.listchars:append({ tab = "»·", trail = "·", nbsp = "·" })
vim.opt.mouse = ""
vim.opt.backup = false
vim.opt.joinspaces = false  -- Use one space, not two, after punctuation
vim.opt.modeline = false  -- Disable modelines as a security precaution
vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.ruler = true  -- Show cursor position all the time
vim.opt.shiftround = true
vim.opt.shiftwidth = 2
vim.opt.shortmess:append("c")
vim.opt.showcmd = true  -- Display incomplete commands
vim.opt.signcolumn = "yes"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.textwidth = 80
vim.opt.updatetime = 300

-- When reading a buffer, jump to last known cursor position except for
-- commit messages, when position is invalid, or inside an event handler.
vim.api.nvim_create_augroup("lastcursorposition", {})
vim.api.nvim_create_autocmd("BufReadPost", {
  group = "lastcursorposition",
  pattern = "*",
  callback = function()
    if vim.fn.expand("<afile>:t") ~= "COMMIT_EDITMSG" and vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
      vim.cmd("normal! g`\"")
    end
  end,
})

-- Disable spelling by default, enable per-filetype
vim.api.nvim_create_autocmd("BufRead", {
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- Fuzzy-find files
vim.api.nvim_set_keymap('n', '<C-p>', ':Files<CR>', { noremap = true, silent = true })
vim.g.fzf_layout = { window = { width = 0.95, height = 0.9 } }

-- Search file contents
vim.api.nvim_set_keymap('n', '\\', ':Ag<SPACE>', { noremap = true, silent = true })
vim.opt.grepprg = "ag --nogroup --nocolor"

-- Bind K to grep word under cursor. Use as fallback when `gr` via LSP doesn't work.
vim.api.nvim_set_keymap('n', 'K', ':grep! "\\b<C-R><C-W>\\b"<CR>:cw<CR>', { noremap = true, silent = true })

-- Switch between the last two files
vim.api.nvim_set_keymap('n', '<Leader><Leader>', '<C-^>', { noremap = true, silent = true })

-- Run tests
vim.api.nvim_set_keymap('n', '<Leader>t', ':TestFile<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>s', ':TestNearest<CR>', { noremap = true, silent = true })
vim.g.test_strategy = "neovim"
vim.g.test_neovim_start_normal = 1
vim.g.test_echo_command = 0

-- Move between windows
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

-- Lua configuration
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- LSP
  use 'neovim/nvim-lspconfig'

  -- Completion
  use 'hrsh7th/cmp-nvim-lsp' -- complete with LSP
  use 'hrsh7th/cmp-buffer'   -- complete words from current buffer
  use 'hrsh7th/cmp-path'     -- complete file paths
  use 'hrsh7th/cmp-cmdline'  -- complete on command-line
  use 'hrsh7th/nvim-cmp'     -- core completion plugin framework

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'nvim-treesitter/playground'
  use 'RRethy/nvim-treesitter-endwise'

  -- Fuzzy-finding :Ag, :Commits, :Files
  use '/opt/homebrew/opt/fzf'
  use 'junegunn/fzf.vim'

  -- :help ale
  use 'dense-analysis/ale'

  -- :help projectionist, .projections.json, :A
  use 'tpope/vim-projectionist'

  -- :TestFile, :TestNearest
  use 'vim-test/vim-test'

  -- Filesystem, :Rename, :Git blame
  use 'pbrisbin/vim-mkdir'
  use 'tpope/vim-eunuch'
  use 'tpope/vim-fugitive'

  -- Alignment, auto pairs, auto tags
  use 'alvan/vim-closetag'
  use 'windwp/nvim-autopairs'

  -- Frontends
  use 'leafgarland/typescript-vim'
  use 'mxw/vim-jsx'
  use 'pangloss/vim-javascript'

  -- Backends
  use {
    'fatih/vim-go',
    run = ':GoInstallBinaries'
  }
  use 'tpope/vim-rails'
  use 'vim-ruby/vim-ruby'
end)

local lspconfig = require('lspconfig')
local cmp = require('cmp')

local on_attach = function(_, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gh', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
end

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Go
lspconfig.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- HTML
lspconfig.html.setup{}

-- Ruby
lspconfig.solargraph.setup{
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "solargraph", "stdio" },
  filetypes = { "ruby" },
  root_dir = lspconfig.util.root_pattern("Gemfile", ".git"),
  settings = {
    solargraph = {
      diagnostics = false
    }
  }
}

-- TypeScript
lspconfig.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern("package.json"),
}
vim.g.markdown_fenced_languages = {
  "ts=typescript"
}

-- Lua
lspconfig.lua_ls.setup {
  cmd = { "lua-language-server" },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

-- Completion
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<TAB>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    { name = 'buffer' },
  })
})

cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Treesitter
require'nvim-treesitter.configs'.setup {
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
    "yaml"
  },
  auto_install = true,
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
  },
  textobjects = {
    enable = true,
  },
  endwise = {
    enable = true,
  },
}

require "nvim-treesitter.configs".setup {
  playground = {
    enable = true,
    disable = {},
    updatetime = 25,
    persist_queries = false,
    keybindings = {
      toggle_query_editor = 'o',
      toggle_hl_groups = 'i',
      toggle_injected_languages = 't',
      toggle_anonymous_nodes = 'a',
      toggle_language_display = 'I',
      focus_language = 'f',
      unfocus_language = 'F',
      update = 'R',
      goto_node = '<cr>',
      show_help = '?',
    },
  }
}

-- Colors
vim.cmd [[hi clear]]

if vim.fn.exists("syntax_on") then
  vim.cmd [[syntax reset]]
end

-- Delegate most highlighting decisions to Treesitter
-- https://neovim.io/doc/user/treesitter.html#treesitter-highlight

-- See highlight group under cursor
-- :TSHighlightCapturesUnderCursor

-- Show all syntax groups
-- :so $VIMRUNTIME/syntax/hitest.vim

vim.cmd [[
" Sync w/ shell/kitty.conf background
hi Normal                               guibg=#191e2d
hi SignColumn                           guibg=#191e2d
hi StatusLine            guifg=#191e2d

hi Identifier            guifg=#ffffff
hi Keyword               guifg=#ffffff

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

hi DiagnosticWarn        guifg=#ffd080
hi Type                  guifg=#ffd080
hi RedrawDebugClear      guifg=#ffd080  guibg=#191e2d
hi Search                               guibg=#ffd080
hi String                guifg=#ffd080
hi WildMenu                             guibg=#d7005f

hi @conditional          guifg=#9664c8
hi Directory             guifg=#9664c8
hi Function              guifg=#9664c8
hi PreProc               guifg=#9664c8

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

hi @diff.plus            guifg=#64c88e
hi @text.diff.add        guifg=#64c88e
]]
