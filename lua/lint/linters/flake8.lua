-- path/to/file:line:col: code message
local pattern = '[^:]+:(%d+):(%d+):(%w+):(.+)'
local groups = { 'line', 'start_col', 'code', 'message' }

return {
  cmd = 'flake8',
  stdin = false,
  args = {
    '--format=%(path)s:%(row)d:%(col)d:%(code)s:%(text)s',
    '--no-show-source',
  },
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, nil, {
    ['source'] = 'flake8',
    ['severity'] = vim.lsp.protocol.DiagnosticSeverity.Warning,
  }),
}
