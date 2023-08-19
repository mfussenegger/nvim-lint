-- error: path/to/file:line:col: message
local pattern = '[^:]+:[^:]+:(%d+):(%d+):(.+)'
local groups = { 'lnum', 'col', 'message' }

return {
  cmd = 'janet',
  stdin = true,
  args = {
    '-k',
  },
  stream = 'stderr',
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, nil, {
    ['source'] = 'janet',
    ['severity'] = vim.diagnostic.severity.ERROR,
  }),
}
