local pattern = [[%s*(%d+):(%d+)%s+(%w+)%s+(.+%S)%s+(%S+)]]
local groups = { 'line', 'start_col', 'severity', 'message', 'code' }
local severity_map = {
  ['error'] = vim.lsp.protocol.DiagnosticSeverity.Error,
  ['warn'] = vim.lsp.protocol.DiagnosticSeverity.Warning,
  ['warning'] = vim.lsp.protocol.DiagnosticSeverity.Warning,
}

return {
  cmd = 'eslint',
  args = {},
  stdin = false,
  stream = 'stdout',
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, severity_map, { ['source'] = 'eslint' }),
}
