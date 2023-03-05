set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

lua <<EOF
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<TAB>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = false }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
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

  local on_attach = function(client, bufnr)
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gh', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'gn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  end

  local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
  local lspconfig = require('lspconfig')
  local util = require('lspconfig.util')

  -- HTML
  lspconfig['html'].setup{}

  -- SQL, configure database connections in $LAPTOP/sql/sqls.yml
  lspconfig['sqls'].setup{}

  -- Go
  lspconfig['gopls'].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }

  -- TypeScript
  lspconfig['tsserver'].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    root_dir = util.root_pattern("package.json"),
  }
  vim.g.markdown_fenced_languages = {
    "ts=typescript"
  }

  -- Deno
  -- https://deno.land/manual/getting_started/setup_your_environment#neovim-06-using-the-built-in-language-server
  -- lspconfig['deno'].setup {
  --   on_attach = on_attach,
  --   capabilities = capabilities,
  --   root_dir = util.root_pattern("deno.json", "deno.jsonc"),
  -- }

  -- Svelte
  lspconfig['svelte'].setup{
    on_attach = on_attach,
    capabilities = capabilities,
  }

  -- Ruby
  lspconfig['ruby_ls'].setup{
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "ruby-lsp" },
    filetypes = { "ruby" },
    init_options = {
      enabledFeatures = { "codeActions", "diagnostics", "documentHighlights", "documentSymbols", "inlayHint" }
    },
    root_dir = util.root_pattern("Gemfile", ".git")
  }

  -- Crystal
  lspconfig['crystalline'].setup{
    on_attach = on_attach,
    capabilities = capabilities,
  }

  -- Auto pairs
  require'nvim-autopairs'.setup {}

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
      "nix",
      "ruby",
      "sql",
      "svelte",
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
      updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
      persist_queries = false, -- Whether the query persists across vim sessions
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

  -- vim.lsp.set_log_level("debug")
EOF
