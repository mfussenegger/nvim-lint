local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  style_problem = vim.diagnostic.severity.HINT,
}

return {
  cmd = 'vint',
  stdin = false,
  args = {
    '--enable-neovim',
    '--style-problem',
    '--json',
  },
  ignore_exitcode = true,
  parser = function(output)
    local diagnostics = {}
    local items = #output > 0 and vim.json.decode(output) or {}
    for _, item in ipairs(items) do
      local row = item.line_number - 1
      local col = item.column_number - 1
      table.insert(diagnostics, {
        source = 'vint',
        lnum = row,
        col = col,
        end_lnum = row,
        end_col = col,
        severity = severities[item.severity],
        message = item.description,
        user_data = {
          lsp = {
            code = item.policy_name,
          },
        }
      })
    end

    return diagnostics
  end,
}
