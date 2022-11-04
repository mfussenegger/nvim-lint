-- path/to/file:line:severity:code:message
local pattern = '([^:]+):(%d+):(%a+):(.+):(.+)'
local groups = { 'file', 'lnum', 'severity', 'code', 'message' }
local severity_map = {
  ['error'] = vim.diagnostic.severity.ERROR,
  ['warning'] = vim.diagnostic.severity.WARN,
  ['info'] = vim.diagnostic.severity.INFO,
}

return {
  cmd = 'oelint-adv',
  stdin = false,
  args = {
    '--quiet',
    '--messageformat={path}:{line}:{severity}:{id}:{msg}',
  },
  ignore_exitcode = true,
  stream = 'stderr',
  parser = require('lint.parser').from_pattern(
    pattern, groups, severity_map,
    { ['source'] = 'oelint-adv' }
  ),
}
