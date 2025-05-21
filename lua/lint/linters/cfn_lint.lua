local pattern = "[^:]+:(%d+):(%d+):(%d+):(%d+):(%w)(%d+):(.*)"
local groups = { "lnum", "col", "end_lnum", "end_col", "severity", "code", "message" }
local severity_map = {
  ["W"] = vim.diagnostic.severity.WARN,
  ["E"] = vim.diagnostic.severity.ERROR,
}

return {
  cmd = "cfn-lint",
  args = { "--format", "parseable" },
  stdin = true,
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severity_map, { ["source"] = "cfn-lint" }),
}
