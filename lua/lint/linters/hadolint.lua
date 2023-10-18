local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  info = vim.diagnostic.severity.INFO,
  style = vim.diagnostic.severity.HINT,
}

return {
  cmd = 'hadolint',
  stdin = true,
  stream = 'stdout',
  ignore_exitcode = true,
  args = {'-f', 'json', '-'},
  parser = function(output)
    local findings = vim.json.decode(output)
    local diagnostics = {}

    for _, finding in pairs(findings or {}) do
      table.insert(diagnostics, {
        lnum = finding.line - 1,
        col = finding.column,
        end_lnum = finding.line - 1,
        end_col = finding.column,
        severity = assert(severities[finding.level], 'missing mapping for severity ' .. finding.level),
        message = finding.message,
        source = 'hadolint',
        code = finding.code,
      })
    end

    return diagnostics
  end,
}
