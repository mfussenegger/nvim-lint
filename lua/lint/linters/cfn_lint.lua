local pattern = "([^:]+):(%d+):(%d+):(%d+):(%d+):(%w)(%d+):(.*)"
local groups = { "file", "lnum", "col", "end_lnum", "end_col", "severity", "code", "message" }
local severity_map = {
  ["W"] = vim.diagnostic.severity.WARN,
  ["E"] = vim.diagnostic.severity.ERROR,
}

return {
  cmd = "cfn-lint",
  args = { "--format", "parseable" },
  stdin = false,
  parser = require("lint.parser").from_pattern(pattern, groups, severity_map, { ["source"] = "cfn-lint" }),
}
