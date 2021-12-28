-- path/to/file:line: message
local pattern = '([^:]+):(%d+):(.*)'
local groups = { 'file', 'lnum', 'message' }

return {
  cmd = 'vulture',
  stdin = false,
  args = {},
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, nil, {
    ['source'] = 'vulture',
    ['severity'] = vim.diagnostic.severity.WARN,
  }),
}
