-- path/to/file:line: message [code]
local pattern = '([^:]+):(%d+): (.+) %[(.+)%]'
local groups = { 'file', 'lnum', 'message', 'code' }

return {
  cmd = 'cmakelint',
  stdin = false,
  args = {'--quiet'},
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, nil, {
    ['source'] = 'cmakelint',
    ['severity'] = vim.diagnostic.severity.WARN,
  }),
}
