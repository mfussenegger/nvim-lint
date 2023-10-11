local pattern = "line (%d+), col (%d+), (.*)"
local groups = { "lnum", "col", "message" }
local severities = nil -- none provided

return {
  cmd = 'jsonlint',
  stream = 'stderr',
  args = { '--compact' },
  stdin = true,
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, severities, {
    source = 'jsonlint',
    severity = vim.diagnostic.severity.ERROR,
  }),
}
