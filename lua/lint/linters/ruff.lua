-- path/to/file:line:col: code message
local pattern = '[^:]+:(%d+):(%d+): (%w+) (.+)'
local groups = { 'lnum', 'col', 'code', 'message' }

return {
  cmd = 'ruff',
  stdin = true,
  args = {
    '--quiet',
    '-',
  },
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, nil, {
    ['source'] = 'ruff',
    ['severity'] = vim.diagnostic.severity.WARN,
  }),
}
