local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
  info = vim.lsp.protocol.DiagnosticSeverity.Information,
}

return {
  cmd = 'hadolint',
  stdin = true,
  stream = 'stdout',
  ignore_exitcode = true,
  args = {'-f', 'json', '-'},
  parser = function(output)
    local findings = vim.fn.json_decode(output)
    local diagnostics = {}

    for _, finding in pairs(findings or {}) do
      table.insert(diagnostics, {
        range = {
          ['start'] = {
            line = finding.line - 1,
            character = finding.column,
          },
          ['end'] = {
            line = finding.line - 1,
            character = finding.column,
          },
        },
        severity = assert(severities[finding.level], 'missing mapping for severity ' .. finding.level),
        message = finding.message,
      })
    end

    return diagnostics
  end,
}
