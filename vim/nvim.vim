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

  -- Ruby
  lspconfig['solargraph'].setup {
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

  require'nvim-treesitter.configs'.setup {
    ensure_installed = {
      "bash",
      "css",
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
    indent = {
      enable = true,
      disable = {"html", "ruby"}
    },
    endwise = {
      enable = true,
    },
  }

  require'nvim-autopairs'.setup {}
EOF
