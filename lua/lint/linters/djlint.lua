local pattern = [[([^:]+):(%d+):(%d+):(%d+): (.*)]]
local groups = { 'file', 'lnum', 'col', 'code', 'message' }

local defaults = {
  ['source'] = 'djlint',
  ['severity'] = vim.diagnostic.severity.INFO
}

return {
  cmd = 'djlint',
  stdin = false,
  args = {
    '--linter-output-format',
    '{filename}:{line}:{code}: {message}',
  },
  stream = 'both',
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, nil, defaults, {}),
}
