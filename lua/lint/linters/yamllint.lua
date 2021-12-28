-- path/to/file:line:col: [severity] message (code)
local pattern = '([^:]+):(%d+):(%d+): %[(.+)%] (.+) %((.+)%)'
local groups = { 'file', 'lnum', 'col', 'severity', 'message', 'code' }
local severities = {
  ['error'] = vim.diagnostic.severity.ERROR,
  ['warning'] = vim.diagnostic.severity.WARN,
}

return {
  cmd = 'yamllint',
  stdin = false,
  args = {'--format=parsable'},
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, severities, {
    ['source'] = 'yamllint',
  }),
}
