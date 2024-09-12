local pattern = "%[%a%]%s+(.+)%s+([^:]+):(%d+):?(%d*)%s+(.*)"
local groups = { "severity", "file", "lnum", "col", "message" }
local severity = {
  ["↑"] = vim.diagnostic.severity.ERROR,
  ["↗"] = vim.diagnostic.severity.WARN,
  ["→"] = vim.diagnostic.severity.INFO,
  ["↘"] = vim.diagnostic.severity.HINT,
  ["↓"] = vim.diagnostic.severity.HINT,
}

return {
  cmd = "mix",
  stdin = false,
  args = { "credo", "list", "--format=oneline", "--strict" },
  stream = "stdout",
  ignore_exitcode = true, -- credo only returns 0 if there are no errors
  parser = require("lint.parser").from_pattern(pattern, groups, severity, { ["source"] = "credo" }),
}
