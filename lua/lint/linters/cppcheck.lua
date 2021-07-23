local pattern = [[([^:]*):(%d*):(%d*): %[([^%]\]*)%] ([^:]*): (.*)]]
local groups = { 'file', 'line', 'start_col', 'code', 'severity', 'message' }
local severity_map = {
  ['error'] = vim.lsp.protocol.DiagnosticSeverity.Error,
  ['warning'] = vim.lsp.protocol.DiagnosticSeverity.Warning,
  ['performance'] = vim.lsp.protocol.DiagnosticSeverity.Warning,
  ['style'] = vim.lsp.protocol.DiagnosticSeverity.Information,
  ['information'] = vim.lsp.protocol.DiagnosticSeverity.Information,
}

return {
  cmd = 'cppcheck',
  stdin = false,
  args = {
    '--enable=warning,style,performance,information',
    '--language=c++',
    '--inline-suppr',
    '--quiet',
    '--cppcheck-build-dir=build',
    '--template={file}:{line}:{column}: [{id}] {severity}: {message}',
  },
  stream = 'stderr',
  parser = require('lint.parser').from_pattern(pattern, groups, severity_map, { ['source'] = 'cppcheck' }),
}
