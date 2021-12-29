-- path/to/file:line: (severity/severity_id) message
local pattern = '([^:]+):(%d+): %((.+)/%d%) (.+)'
local groups = { 'file', 'lnum', 'severity', 'message' }
local severities = {
  INFO = vim.diagnostic.severity.INFO,
  WARNING = vim.diagnostic.severity.WARN,
  ERROR = vim.diagnostic.severity.ERROR,
  SEVERE = vim.diagnostic.severity.ERROR,
}

return {
  cmd = 'rstcheck',
  stdin = false,
  stream = 'stderr',
  args = {},
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, severities, {
    ['source'] = 'rstcheck',
  }),
}
