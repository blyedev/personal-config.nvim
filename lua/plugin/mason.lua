local M = {}

function M.setup()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

  local servers = {
    angularls = {},
    tsserver = {},
    eslint = {},
    lua_ls = {
      settings = {
        Lua = {
          completion = {
            callSnippet = 'Replace',
          },
        },
      },
    },
    ruff_lsp = {},
    jsonls = {},
    ['nginx-language-server'] = {},
  }

  require('mason').setup()

  local ensure_installed = vim.tbl_keys(servers or {})
  vim.list_extend(ensure_installed, {
    'stylua',
    'jdtls',
    'markdownlint',
  })
  require('mason-tool-installer').setup { ensure_installed = ensure_installed }

  require('mason-lspconfig').setup {
    handlers = {
      function(server_name)
        local server = servers[server_name] or {}
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        require('lspconfig')[server_name].setup(server)
      end,
      jdtls = function() end,
    },
  }
end

return M
