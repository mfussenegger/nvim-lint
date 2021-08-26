local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
  info = vim.lsp.protocol.DiagnosticSeverity.Information,
  style = vim.lsp.protocol.DiagnosticSeverity.Hint,
}

return {
  cmd = 'shellcheck',
  stdin = true,
  args = {
    '--format', 'json',
    '-',
  },
  ignore_exitcode = true,
  parser = function(output)
    local decoded = vim.fn.json_decode(output)
    local diagnostics = {}
    for _, item in ipairs(decoded or {}) do
      table.insert(diagnostics, {
        range = {
          ['start'] = {
            line = item.line - 1,
            character = item.column - 1,
          },
          ['end'] = {
            line = item.endLine - 1,
            character = item.endColumn - 1,
          },
        },
        code = item.code,
        severity = assert(severities[item.level], 'missing mapping for severity ' .. item.level),
        message = item.message,
      })
    end
    return diagnostics
  end,
}
