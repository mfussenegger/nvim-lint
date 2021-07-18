local pattern = 'line (%d+) column (%d+) %- (%a+): (.+)'
local groups = { 'lineno', 'colno', 'severity', 'message' }
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

return {
  cmd = 'tidy',
  stdin = true,
  stream = 'stderr',
  args = {
    '-quiet',
    '-errors',
    '-language',
    'en',
    '--gnu-emacs',
    'yes',
  },
  parser = require('lint.parser').from_pattern(pattern, groups, severities, { ['source'] = 'tidy' }),
}
