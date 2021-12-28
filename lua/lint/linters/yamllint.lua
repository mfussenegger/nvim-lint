-- path/to/file:line:col: [severity] message
local pattern = '([^:]+):(%d+):(%d+): %[(.+)%] (.+)'
local groups = { 'file', 'lnum', 'col', 'severity', 'message' }
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
