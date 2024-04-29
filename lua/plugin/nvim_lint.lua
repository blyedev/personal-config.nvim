local M = {}

function M.setup()
  local lint = require 'lint'
  lint.linters_by_ft = {
    markdown = { 'markdownlint' },
    yaml = { 'actionLint' },
  }

  -- To allow other plugins to add linters to require('lint').linters_by_ft,
  -- instead set linters_by_ft like this:
  -- lint.linters_by_ft = lint.linters_by_ft or {}
  -- lint.linters_by_ft['markdown'] = { 'markdownlint' }

  -- You can disable the default linters by setting their filetypes to nil:

  -- Create autocommand which carries out the actual linting
  -- on the specified events.
  local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
    group = lint_augroup,
    callback = function()
      require('lint').try_lint()
    end,
  })
end

return M
