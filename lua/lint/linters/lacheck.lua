-- path/to/file, line <linum>: <message>
local pattern = '[^:]+, line (%d+):(.+)'
local groups = { 'lnum', 'message' }

return {
  cmd = 'lacheck',
  stdin = false,
  args = {},
  stream = 'stdout',
  ignore_exitcode = false,
  parser = require('lint.parser').from_pattern(pattern, groups, nil, {
    ["source"] = "lacheck",
    ['severity'] = vim.diagnostic.severity.WARN,
  }),
}
