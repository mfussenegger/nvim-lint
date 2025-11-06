local pattern = "([^:]+):(%d+):(%d+):%s*([A-Z%d]+)%s+(.+)"
local groups = { "file", "lnum", "col", "code", "message" }
local defaults = { ["source"] = "mado", ["severity"] = vim.diagnostic.severity.WARN }

return {
  cmd = "mado",
  args = { "check", "--quiet" },
  stdin = false,
  stream = "stdout",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, nil, defaults),
}
