-- format.nvim
--

local M = {}

M.keys = {
  {
    '<leader>f',
    function()
      require('conform').format { async = true, lsp_fallback = true }
    end,
    mode = '',
    desc = '[F]ormat buffer',
  },
}

M.opts = {
  notify_on_error = false,
  format_on_save = false,
  formatters_by_ft = {
    lua = { 'stylua' },
    markdown = { 'markdownlint' },
    -- python = { "isort", "black" },
    --
    -- You can use a sub-list to tell conform to run *until* a formatter
    -- is found.
    javascript = { { 'prettierd', 'prettier' } },
    typescript = { { 'prettierd', 'prettier' } },
    html = { { 'prettierd', 'prettier' } },
  },
}

return M
