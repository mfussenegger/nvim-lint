local pattern = ":(%d+):.-\n*%^%s*(%S.*)"
local groups = { "lnum", "message" }

return {
  cmd = "awk",
  stdin = true,
  args = { "-f-", "-L" },
  stream = "stderr",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, nil, {
    source = "awk",
    severity = vim.diagnostic.severity.ERROR,
  }),
}
