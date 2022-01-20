-- Example output:
--   $ zig ast-check < test.zig
--   <stdin>:5:16: error: use of undeclared identifier 'foobar'
local pattern = '^<stdin>:(%d+):(%d+): (%w+): (.+)$'
local groups = { 'lnum', 'col', 'severity', 'message' }
local severity_map = {
  ["error"] = vim.diagnostic.severity.ERROR,
}

return {
  cmd = 'zig',
  args = {
    'ast-check',
  },
  stdin = true,
  stream = 'stderr',
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, severity_map, {
    source = 'zig ast-check',
  }),
}
