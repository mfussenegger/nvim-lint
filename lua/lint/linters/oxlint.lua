local pattern = "::([^ ]+) file=(.*),line=(%d+),endLine=(%d+),col=(%d+),endColumn=(%d+),title=(.*)::(.*)"
local severities = {
  ["error"] = vim.diagnostic.severity.ERROR,
  ["warning"] = vim.diagnostic.severity.WARN,
}
local groups = { "severity", "file", "lnum", "end_lnum", "col", "end_col", "code", "message" }
local defaults = { ["source"] = "oxlint" }

return {
  cmd = "oxlint",
  stdin = false,
  args = { "--format", "github" },
  stream = "stdout",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severities, defaults, {})
}
