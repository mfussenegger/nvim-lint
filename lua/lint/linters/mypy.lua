-- path/to/file:line:col: severity: message
local pattern = '([^:]+):(%d+):(%d+): (%a+): (.*)'
local groups = { 'file', 'lineno', 'colno', 'severity', 'msg' }
local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
  note = vim.lsp.protocol.DiagnosticSeverity.Hint,
}

return {
  cmd = 'mypy',
  stdin = false,
  args = {
    '--show-column-numbers',
    '--hide-error-codes',
    '--hide-error-context',
    '--no-color-output',
    '--no-error-summary',
    '--no-pretty',
  },
  parser = require('lint.parser').from_pattern(pattern, groups, severities, { ['source'] = 'mypy' }),
}
