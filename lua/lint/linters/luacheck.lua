local pattern = '[^:]+:(%d+):(%d+)-(%d+): %((%a)(%d+)%) (.*)'
local groups = { 'lnum', 'col', 'end_col', 'severity', 'code', 'message' }
local severities = {
  W = vim.diagnostic.severity.WARN,
  E = vim.diagnostic.severity.ERROR,
}

return {
  cmd = 'luacheck',
  stdin = true,
  args = { '--formatter', 'plain', '--codes', '--ranges', '-' },
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(
    pattern,
    groups,
    severities,
    { ['source'] = 'luacheck' },
    { end_col_offset = 0 }
  ),
}
