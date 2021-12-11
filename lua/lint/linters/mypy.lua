-- path/to/file:line:col: severity: message
local pattern = '([^:]+):(%d+):(%d+): (%a+): (.*)'
local groups = { 'file', 'lnum', 'col', 'severity', 'message' }
local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  note = vim.diagnostic.severity.HINT,
}

return {
  cmd = 'mypy',
  stdin = false,
  ignore_exitcode = true,
  args = {
    '--show-column-numbers',
    '--hide-error-codes',
    '--hide-error-context',
    '--no-color-output',
    '--no-error-summary',
    '--no-pretty',
  },
  parser = require('lint.parser').from_pattern(pattern, groups, severities, { ['source'] = 'mypy' }),
}
