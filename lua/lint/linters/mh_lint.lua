local pattern = "^(.-):(%d+):(%d+):%s*([^:]+):%s*(.*)$"
local groups = { "file", "lnum", "col", "severity", "message" }
local severities = {
  ["check (high)"] = vim.diagnostic.severity.ERROR,
  ["check (medium)"] = vim.diagnostic.severity.WARN,
  ["check (low)"] = vim.diagnostic.severity.INFO,
}
local defaults = { source = "mh_lint" }

return {
  cmd = "mh_lint",
  stdin = false,
  args = { "--brief" },
  stream = "stdout",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severities, defaults, { col_offset = 0 }),
}
