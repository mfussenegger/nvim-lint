-- stdin:line:col: [severity] message (code)
local pattern = 'stdin:(%d+):(%d+): %[(.+)%] (.+) %((.+)%)'
local groups = { 'lnum', 'col', 'severity', 'message', 'code' }
local severities = {
  ['error'] = vim.diagnostic.severity.ERROR,
  ['warning'] = vim.diagnostic.severity.WARN,
}

return {
  cmd = 'yamllint',
  stdin = true,
  stream = 'stdout',
  args = {'--format', 'parsable', '-'},
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, severities, {
    ['source'] = 'yamllint',
  }),
}
