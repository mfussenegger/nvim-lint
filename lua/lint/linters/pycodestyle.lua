-- path/to/file:line:col:code:message
local pattern = '[^:]+:(%d+):(%d+):(%w+):(.+)'
local groups = { 'line', 'start_col', 'code', 'message' }

return {
  cmd = 'pycodestyle',
  stdin = true,
  args = {
    '--format=%(path)s:%(row)d:%(col)d:%(code)s:%(text)s',
    '-',
  },
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, nil, {
    ['source'] = 'pycodestyle',
    ['severity'] = vim.lsp.protocol.DiagnosticSeverity.Warning,
  }),
}
