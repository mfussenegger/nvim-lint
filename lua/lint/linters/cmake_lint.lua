local pattern = "([^:]+):(%d+):%s%[(%w+%d+)%]%s(.+)"
local groups = { "file", "lnum", "code", "message" }
local defaults = { source = "cmake-lint", severity = vim.diagnostic.severity.WARN }

return {
  cmd = "cmake-lint",
  args = { "--suppress-decorations" },
  stdin = false,
  stream = "stdout",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, nil, defaults),
}
