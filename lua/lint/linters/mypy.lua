local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
  note = vim.lsp.protocol.DiagnosticSeverity.Hint,
}

-- path/to/file:line:col: severity: message
local pattern  = "([^:]+):(%d+):(%d+): (%a+): (.*)"

return {
  cmd = 'mypy',
  stdin = false,
  args = {
    '--show-column-numbers',
    '--no-error-summary',
  },
  parser = function(output, bufnr)
    local result = vim.fn.split(output, "\n")
    local diagnostics = {}
    local buf_file = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ':~:.')

    for _, message in ipairs(result) do
      local file, lineno, offset, severity, msg = string.match(message, pattern)
      -- We should only report the errors found in the current file as mypy can
      -- follow the `imports` and report the errors from those files as well.
      if file == buf_file then
        lineno = tonumber(lineno or 1) - 1
        offset = tonumber(offset or 1) - 1
        table.insert(diagnostics, {
          source = 'mypy',
          range = {
            ['start'] = {line = lineno, character = offset},
            ['end'] = {line = lineno, character = offset + 1}
          },
          message = msg,
          severity = assert(severities[severity], 'missing mapping for severity ' .. severity),
        })
      end
    end
    return diagnostics
  end
}
