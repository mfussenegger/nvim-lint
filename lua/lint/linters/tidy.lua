local severities = {
  Info = vim.lsp.protocol.DiagnosticSeverity.Information,
  Warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
  Config = vim.lsp.protocol.DiagnosticSeverity.Error,
  Access = vim.lsp.protocol.DiagnosticSeverity.Information,
  Error = vim.lsp.protocol.DiagnosticSeverity.Error,
  Document = vim.lsp.protocol.DiagnosticSeverity.Error,
  Panic = vim.lsp.protocol.DiagnosticSeverity.Error,
  Summary = vim.lsp.protocol.DiagnosticSeverity.Information,
  Information = vim.lsp.protocol.DiagnosticSeverity.Information,
  Footnote = vim.lsp.protocol.DiagnosticSeverity.Information,
}

local pattern = 'line (%d+) column (%d+) %- (%a+): (.+)'

return {
  cmd = 'tidy',
  stdin = true,
  stream = 'stderr',
  args = {
    '-quiet',
    '-errors',
    '-language', 'en',
    '--gnu-emacs', 'yes',
  },
  parser = function(output, bufnr)
    local diagnostics = {}
    for item in vim.gsplit(output, '\n') do
      local line, column, severity, message = string.match(item, pattern)
      if line and column then
        table.insert(diagnostics, {
          source = 'tidy',
          range = {
            ['start'] = {
              line = tonumber(line) - 1,
              character = tonumber(column) - 1,
            },
            ['end'] = {
              line = tonumber(line) - 1,
              character = tonumber(column),
            },
          },
          message = message,
          severity = assert(severities[severity], 'missing mapping for severity ' .. severity),
        })
      end
    end
    return diagnostics
  end,
}
