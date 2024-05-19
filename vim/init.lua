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
vim.opt.exrc = true                     -- Project-specific vimrc
vim.opt.fillchars:append({ eob = " " }) -- Hide ~ end-of-file markers
vim.opt.hidden = true                   -- Allow switching between buffers without saving
vim.opt.history = 50
vim.opt.incsearch = true
vim.opt.joinspaces = false -- Use one space, not two, after punctuation
vim.opt.laststatus = 2     -- Always display status line
vim.opt.list = true
vim.opt.listchars:append({ tab = "»·", trail = "·", nbsp = "·" })
vim.opt.modeline = false -- Disable modelines as a security precaution
vim.opt.mouse = ""
vim.opt.ruler = true     -- Show cursor position all the time
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

-- Packer
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

local function format_on_save(cmd_template)
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = 0,
    callback = function()
      local buffer_file = vim.fn.expand("%:p")
      -- Replace % placeholder in command template with actual file path
      local cmd = cmd_template:gsub("%%", buffer_file)

      -- Run async to prevent blocking main thread
      vim.fn.jobstart(cmd, {
        stdout_buffered = true,  -- Buffer stdout to handle in one go
        on_stdout = function(_, data)
          if not data then
            return
          end

          local formatted_content = table.concat(data, "\n")
          if #formatted_content == 0 then
            return
          end

          local pos = vim.api.nvim_win_get_cursor(0)  -- Save current cursor position
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
        end
      })
    end
  })
end

-- LSPs
local lspconfig = require('lspconfig')

local on_attach = function(_, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gh', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
end

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Go
lspconfig.gopls.setup {
  capabilities = capabilities,
  on_attach = on_attach
}
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", },
  callback = function()
    -- $LAPTOP/bin/goimportslocal
    vim.g.go_fmt_command = 'goimportslocal'
    vim.g.go_rename_command = 'gopls'

    -- https://github.com/golang/tools/blob/master/gopls/doc/vim.md
    vim.g.go_def_mode = 'gopls'
    vim.g.go_info_mode = 'gopls'

    -- Disable vim-go template
    vim.g.go_template_autocreate = 0

    vim.opt_local.listchars = { tab = "  ", trail = "·", nbsp = "·" }
    vim.opt_local.expandtab = false

    -- Don't highlight tabs as extra whitespace
    vim.opt_local.list = false

    vim.cmd("compiler go")

    vim.api.nvim_buf_set_keymap(0, 'n', ':A<CR>', ':GoAlternate<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', '<Leader>r', ':redraw!<CR>:!go run %<CR>', { noremap = true, silent = true })

    -- Syntax highlight additional tokens
    vim.g.go_highlight_fields = 1
    vim.g.go_highlight_functions = 1
    vim.g.go_highlight_methods = 1
    vim.g.go_highlight_operators = 1
    vim.g.go_highlight_structs = 1
  end
})

-- HTML
lspconfig.html.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html" },
  callback = function()
    -- Format on save
    format_on_save("prettier --parser html %")

    -- Treat <li> and <p> tags like the block tags they are
    vim.g.html_indent_tags = 'li\\|p'
  end
})

-- JSON
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json" },
  callback = function()
    -- Format on save
    format_on_save("prettier --parser json %") -- json5, --json-stringify
  end
})

-- Lua
lspconfig.lua_ls.setup {
  cmd = { "lua-language-server" },
  capabilities = capabilities,
  on_attach = on_attach,
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

-- Markdown
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    -- Format on save
    format_on_save("prettier --parser markdown %")
  end
})

-- Ruby
lspconfig.solargraph.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  cmd = { "solargraph", "stdio" },
  filetypes = { "ruby" },
  root_dir = lspconfig.util.root_pattern("Gemfile", ".git"),
  settings = {
    solargraph = {
      diagnostics = false
    }
  },
}
vim.api.nvim_create_autocmd("FileType", {
  pattern = "ruby",
  callback = function()
    -- Format on save
    format_on_save("cat % | bundle exec rubocop --config ./.rubocop.yml --stderr --stdin % --autocorrect --format quiet")

    -- Run current file
    vim.api.nvim_buf_set_keymap(0, 'n', '<Leader>r', ':redraw!<CR>:!bundle exec ruby %<CR>', { noremap = true, silent = true })

    -- https://github.com/testdouble/standard/wiki/IDE:-vim
    vim.g.ruby_indent_assignment_style = 'variable'
  end
})

-- SCSS
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scss" },
  callback = function()
    -- Format on save
    format_on_save("prettier --parser scss %")
  end
})

-- SQL
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  callback = function()
    -- Format on save
    format_on_save("pg_format --function-case 1 --keyword-case 2 --spaces 2 --no-extra-line %")

    --- Run current file
    vim.api.nvim_buf_set_keymap(0, 'n', '<Leader>r', ':redraw!<CR>:!psql -d $(cat .db) -f % | less<CR>', { noremap = true, silent = true })

    -- Prepare SQL command with var(s)
    vim.api.nvim_buf_set_keymap(0, 'n', '<Leader>v', ':redraw!<CR>:!psql -d $(cat .db) -f % -v | less<SPACE>', { noremap = true, silent = true })
  end
})

-- TypeScript
lspconfig.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern("package.json"),
}
vim.g.markdown_fenced_languages = {
  "ts=typescript"
}
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript" },
  callback = function()
    -- Format on save
    format_on_save("prettier --parser typescript %")
  end
})

-- YAML
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml" },
  callback = function()
    -- Format on save
    format_on_save("prettier --parser yaml %")
  end
})

-- Completion
local cmp = require('cmp')

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

-- Syntax Highlighting
require 'nvim-treesitter.configs'.setup {
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

-- Custom colors after Treesitter
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
