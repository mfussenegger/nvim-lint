local pattern = [[(%d+):(%d+):(%a%d+): (.*)]]
local groups = { 'lnum', 'col', 'code', 'message' }

local defaults = {
  ['source'] = 'djlint',
  ['severity'] = vim.diagnostic.severity.INFO
}

return {
  cmd = 'djlint',
  stdin = true,
  args = {
    '--linter-output-format',
    '{line}:{code}: {message}',
    '-',
  },
  stream = 'both',
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, nil, defaults, {}),
}
