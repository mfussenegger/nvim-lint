-- path/to/file:line: message [code]
local pattern = '([^:]+):(%d+): (.+) %[(.+)%]'
local groups = { 'file', 'lnum', 'message', 'code' }
local is_windows = vim.loop.os_uname().version:match('Windows')

return {
  cmd = is_windows and 'cmakelint.cmd' or 'cmakelint',
  stdin = false,
  args = {'--quiet'},
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, nil, {
    ['source'] = 'cmakelint',
    ['severity'] = vim.diagnostic.severity.WARN,
  }),
}
