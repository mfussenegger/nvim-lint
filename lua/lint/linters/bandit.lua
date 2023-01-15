local pattern = [[(%d+):(%d+):(%u+):(%w+) (.*)]]
local groups = { "lnum", "col", "severity", "code", "message" }

local severity_map = {
  ["HIGH"] = vim.diagnostic.severity.ERROR,
  ["MEDIUM"] = vim.diagnostic.severity.WARN,
  ["LOW"] = vim.diagnostic.severity.INFO,
}

local defaults = {
  source = "bandit",
}

return {
  cmd = "bandit",
  stdin = false,
  args = {
    "-f",
    "custom",
    "--msg-template",
    "{line}:{col}:{severity}:{test_id} {msg}",
  },
  stream = "stdout",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severity_map, defaults, {
    col_offset = 0,
  }),
}
