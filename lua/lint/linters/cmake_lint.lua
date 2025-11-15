local pattern = "([^:]+):(%d+),?(%d*):%s%[((%w)%d+)%]%s(.+)"
local groups = { "file", "lnum", "col", "code", "severity", "message" }
local severity_map = {
  E = vim.diagnostic.severity.ERROR,
  W = vim.diagnostic.severity.WARN,
  R = vim.diagnostic.severity.INFO,
  C = vim.diagnostic.severity.HINT,
}

return {
  cmd = "cmake-lint",
  args = { "--suppress-decorations" },
  stdin = false,
  stream = "stdout",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severity_map, { source = "cmake-lint" }),
}
