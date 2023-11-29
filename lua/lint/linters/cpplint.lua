-- path/to/file:line:  message  [code] [code_id]
local pattern = '([^:]+):(%d+):  (.+)  (.+)'
local groups = { 'file', 'lnum', 'message', 'code'}

return {
  cmd = 'cpplint',
  stdin = false,
  args = {},
  ignore_exitcode = true,
  stream = 'stderr',
  parser = require('lint.parser').from_pattern(pattern, groups, nil, {
    ['source'] = 'cpplint',
    ['severity'] = vim.diagnostic.severity.WARN,
  }),
}
