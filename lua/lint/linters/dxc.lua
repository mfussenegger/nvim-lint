-- example:
--  blur.hlsl:18:6: error: expected ';' after top level declarator
local pattern = "%s*([^:]+):(%d+):(%d+): (.+): (.+)"
local groups = { "file", "lnum", "col", "severity", "message" }

return {
  cmd = "dxc",
  stdin = false,
  args = { "-T", "cs_6_5" },
  ignore_exitcode = true,
  stream = "stderr",
  parser = require("lint.parser").from_pattern(pattern, groups, {
    error = vim.diagnostic.severity.ERROR,
    warning = vim.diagnostic.severity.WARN,
  }, {
    ["source"] = "dxc",
    ["severity"] = vim.diagnostic.severity.WARN,
  }),
}
