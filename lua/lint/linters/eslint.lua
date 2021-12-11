local pattern = [[%s*(%d+):(%d+)%s+(%w+)%s+(.+%S)%s+(%S+)]]
local groups = { 'lnum', 'col', 'severity', 'message', 'code' }
local severity_map = {
  ['error'] = vim.diagnostic.severity.ERROR,
  ['warn'] = vim.diagnostic.severity.WARN,
  ['warning'] = vim.diagnostic.severity.WARN,
}

return {
  cmd = 'eslint',
  args = {},
  stdin = false,
  stream = 'stdout',
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, severity_map, { ['source'] = 'eslint' }),
}
