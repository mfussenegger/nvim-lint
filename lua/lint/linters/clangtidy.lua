local pattern = [[([^:]*):(%d+):(%d+): (%w+): ([^[]+)]]
local groups = { 'file', 'lineno', 'colno', 'severity', 'message' }

local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
}

return {
  cmd = 'clang-tidy',
  stdin = false,
  args = { '--quiet' },
  parser = require('lint.parser').from_pattern(pattern, groups),
}
