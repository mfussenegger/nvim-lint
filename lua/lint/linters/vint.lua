local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
  style_problem = vim.lsp.protocol.DiagnosticSeverity.Hint,
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
    local items = #output > 0 and vim.fn.json_decode(output) or {}
    for _, item in ipairs(items) do
      local row = item.line_number - 1
      local col = item.column_number - 1
      table.insert(diagnostics, {
        source = 'vint',
        range = {
          ['start'] = { line = row, character = col },
          ['end'] = { line = row, character = col },
        },
        severity = severities[item.severity],
        message = item.description,
        code = item.policy_name,
      })
    end

    return diagnostics
  end,
}
