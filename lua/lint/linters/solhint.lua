local pattern = '(%d+):(%d+)%s+(%w+)%s+(.-)%s+(%S+)$'
local groups = { 'lnum', 'col', 'severity', 'message', 'code' }
local severity_map = {
  ['error'] = vim.diagnostic.severity.ERROR,
  ['warning'] = vim.diagnostic.severity.WARN,
}

return {
  cmd = 'solhint',
  stdin = true,
  args = { 'stdin' },
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, severity_map, {
    ['source'] = 'solhint'
  }),
}
