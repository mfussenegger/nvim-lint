-- path/to/file:line:col: code.subcode.subsubcode message
local pattern = '([^:]+):(%d+):(%d+): ([^ ]+) (.*)'
local groups = { 'file', 'lnum', 'col', 'code', 'message' }

return {
  cmd = 'proselint',
  stdin = false,
  args = {},
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, nil, {
    ['source'] = 'proselint',
    ['severity'] = vim.diagnostic.severity.INFO,
  }),
}
