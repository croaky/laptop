set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

let mapleader = " "   " Spacebar

set autoindent
set cmdheight=2
set complete+=kspell  " Include spellfile in completion results
set diffopt+=vertical " Always use vertical diffs
set expandtab
set exrc              " Project-specific vimrc
set fillchars=eob:\   " Hide ~ end-of-file markers
set hidden            " Allow switching between buffers without saving
set history=50
set incsearch
set laststatus=2      " Always display status line
set list listchars=tab:»·,trail:·,nbsp:·
set mouse=
set nobackup
set nojoinspaces      " Use one space, not two, after punctuation
set nomodeline        " Disable modelines as a security precaution
set noswapfile
set nowritebackup
set ruler             " Show cursor position all the time
set shiftround
set shiftwidth=2
set shortmess+=c      " Don't pass messages to |ins-completion-menu|
set showcmd           " Display incomplete commands
set signcolumn=yes
set splitbelow
set splitright
set tabstop=2
set termguicolors
set textwidth=80
set updatetime=300

" When reading a buffer, jump to last known cursor position except for
" commit messages, when position is invalid, or inside an event handler.
augroup lastcursorposition
  autocmd!
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
augroup END

" Lint with ALE
augroup ale
  autocmd!
  autocmd VimEnter *
    \ let g:ale_lint_on_enter = 1 |
    \ let g:ale_lint_on_text_changed = 0
augroup END

" Disable spelling by default, enable per-filetype
autocmd BufRead setlocal nospell

" Fuzzy-find files
nnoremap <C-p> :Files<CR>
let g:fzf_layout = { 'window': { 'width': 0.95, 'height': 0.9 } }

" Search file contents
nnoremap \ :Ag<SPACE>
set grepprg=ag\ --nogroup\ --nocolor

" bind K to grep word under cursor. Use as fallback when `gr` via LSP doesn't work.
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" Switch between the last two files
nnoremap <Leader><Leader> <C-^>

" Run tests https://github.com/vim-test/vim-test#kitty-strategy-setup
nnoremap <silent> <Leader>t :TestFile<CR>
nnoremap <silent> <Leader>s :TestNearest<CR>
let g:test#strategy = "neovim"
let g:test#neovim#start_normal = 1
let g:test#echo_command = 0

" Move between windows
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

lua <<EOF
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
    use 'hrsh7th/nvim-cmp'     -- core complettion plugin framework

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

  local on_attach = function(client, bufnr)
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
EOF

" Colors
hi clear

if exists("syntax_on")
  syntax reset
endif

" Delegate most highlighting decisions to Treesitter
" https://neovim.io/doc/user/treesitter.html#treesitter-highlight

" See highlight group under cursor
" :TSHighlightCapturesUnderCursor

" Show all syntax groups
" :so $VIMRUNTIME/syntax/hitest.vim

" Sync w/ shell/kitty.conf background
hi Normal                               guibg=#191e2d
hi SignColumn                           guibg=#191e2d
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
