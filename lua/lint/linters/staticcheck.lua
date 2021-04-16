local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
  ignored = vim.lsp.protocol.DiagnosticSeverity.Information,
}

return {
  cmd = 'staticcheck',
  stdin = true,
  args = {
    '-f', 'json',
  },
  ignore_exitcode = true,
  parser = function(output, bufnr)
    local result = vim.fn.split(output, "\n")
    local diagnostics = {}
    for _, message in ipairs(result) do
      local decoded = vim.fn.json_decode(message)
        table.insert(diagnostics, {
          range = {
            ['start'] = {
              line = decoded.location.line - 1,
              character = decoded.location.column - 1,
            },
            ['end'] = {
              line = decoded["end"]["line"] - 1,
              character = decoded["end"]["column"] - 1,
            },
          },
          code = decoded.code,
          severity = assert(severities[decoded.severity], 'missing mapping for severity ' .. decoded.severity),
          message = decoded.message,
        })
    end
    return diagnostics
  end,
}
