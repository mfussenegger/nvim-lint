local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
  refactor = vim.lsp.protocol.DiagnosticSeverity.Information,
  convention = vim.lsp.protocol.DiagnosticSeverity.Hint,
}

return {
  cmd = 'pylint',
  stdin = false,
  args = {
    '-f', 'json'
  },
  parser = function(output, bufnr)
    local decoded = vim.fn.json_decode(output)
    local diagnostics = {}
    for _, item in ipairs(decoded or {}) do
      local column = 0
      if item.column > 0 then
        column = item.column - 1
      end
      table.insert(diagnostics, {
        range = {
          ['start'] = {
            line = item.line - 1,
            character = column,
          },
          ['end'] = {
            line = item.line - 1,
            character = column,
          },
        },
        severity = assert(severities[item.type], 'missing mapping for severity ' .. item.type),
        message = item.message,
      })
    end
    return diagnostics
  end,
}
