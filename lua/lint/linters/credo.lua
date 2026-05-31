local pattern = "%[%a%]%s+(.+)%s+[^:]+:(%d+):?(%d*)%s+(.*)"
local groups = { "severity", "lnum", "col", "message" }
local severity = {
  ["↑"] = vim.diagnostic.severity.ERROR,
  ["↗"] = vim.diagnostic.severity.WARN,
  ["→"] = vim.diagnostic.severity.INFO,
  ["↘"] = vim.diagnostic.severity.HINT,
  ["↓"] = vim.diagnostic.severity.HINT,
}

return {
  cmd = "mix",
  stdin = true,
  args = {
    "credo",
    "list",
    function()
      return vim.api.nvim_buf_get_name(0)
    end,
    "--read-from-stdin",
    "--strict",
    "--format=oneline",
  },
  stream = "stdout",
  ignore_exitcode = true, -- credo only returns 0 if there are no errors
  parser = require("lint.parser").from_pattern(pattern, groups, severity, { ["source"] = "credo" }),
}
