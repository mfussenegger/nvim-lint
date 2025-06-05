local pattern = "(.*):(%d*):(%d*): (.*) %[([EW][arnogi]*)%/([a-z%/%-%(%)]*)%]"
local severities = {
  ["Error"] = vim.diagnostic.severity.ERROR,
  ["Warning"] = vim.diagnostic.severity.WARN,
}
local groups = { "file", "lnum", "col", "message", "severity", "code" }
local defaults = { ["source"] = "oxlint" }

return {
  cmd = "oxlint",
  stdin = false,
  args = { "--format", "unix" },
  stream = "stdout",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severities, defaults, {})
}
