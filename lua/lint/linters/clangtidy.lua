local pattern = [[([^:]*):(%d+):(%d+): (%w+): ([^[]+)]]
local groups = { 'file', 'line', 'start_col', 'severity', 'message' }

local DiagnosticSeverity = vim.lsp.protocol.DiagnosticSeverity

local severity_map = {
  ['error'] = DiagnosticSeverity.Error,
  ['warning'] = DiagnosticSeverity.Warning,
  ['information'] = DiagnosticSeverity.Information,
  ['hint'] = DiagnosticSeverity.Hint,
  ['note'] = DiagnosticSeverity.Hint,
}

return {
  cmd = 'clang-tidy',
  stdin = false,
  args = { '--quiet' },
  parser = require('lint.parser').from_pattern(pattern, groups, severity_map, { ['source'] = 'clang-tidy' }),
}
