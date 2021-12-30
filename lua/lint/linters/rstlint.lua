-- severity path/to/file:line message
local pattern = '(.*) (.*):(%d+) (.*)'
local groups = { 'severity', 'file', 'lnum', 'message' }
local severities = {
  INFO = vim.diagnostic.severity.INFO,
  WARNING = vim.diagnostic.severity.WARN,
  ERROR = vim.diagnostic.severity.ERROR,
  SEVERE = vim.diagnostic.severity.SEVERE,
}

return {
  cmd = 'restructuredtext-lint',
  stdin = false,
  args = {},
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, severities, {
    ['source'] = 'rstlint',
  }),
}
