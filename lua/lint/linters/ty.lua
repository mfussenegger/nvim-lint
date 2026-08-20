local pattern = '([^:]+):(%d+):(%d+): (%a+)%[([%a%-]+)%] (.*)'
local groups = { 'file', 'lnum', 'col', 'severity', 'code', 'message' }
local severities = {
  error = vim.diagnostic.severity.ERROR,
  warn = vim.diagnostic.severity.WARN,
}

return {
  cmd = 'ty',
  stdin = false,
  stream = 'stdout',
  ignore_exitcode = true,
  args = {
    'check',
    '--output-format',
    'concise',
  },
  parser = require('lint.parser').from_pattern(
    pattern,
    groups,
    severities,
    { ['source'] = 'ty' },
    { end_col_offset = 0 }
  ),
}
