local pattern = ".*(Fail)......([^:]+):(%d+):(%d+).*hint: (.+)%."
local groups = { "severity", "file", "lnum", "col", "message" }

local severities = {
  ["Fail"] = vim.diagnostic.severity.WARN,
}

return {
  cmd = "svlint",
  stdin = false,
  stream = "stdout",
  args = {
    "--oneline",
  },
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severities, { ["source"] = "svlint" }),
}
