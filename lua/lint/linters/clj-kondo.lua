local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
}

return {
  cmd = 'clj-kondo',
  stdin = true,
  stream = 'stdout',
  ignore_exitcode = true,
  args = {
    '--config', '{:output {:format :json}}', '--parallel', '--lint', '-',
  },
  parser = function(output)
    local decoded = vim.fn.json_decode(output) or {}
    local findings = decoded.findings
    local diagnostics = {}

    for _, finding in pairs(findings or {}) do
      table.insert(diagnostics, {
        range = {
          ['start'] = {
            line = finding.row - 1,
            character = finding.col,
          },
          ['end'] = {
            line = finding.row - 1,
            character = finding.col,
          },
        },
        severity = assert(severities[finding.level], 'missing mapping for severity ' .. finding.level),
        message = finding.message,
      })
    end

    return diagnostics
  end,
}
