local pattern = "([^:]+):(%d+):(%d+):(%l+):%s*(.+)"
local groups = { "file", "lnum", "col", "severity", "message" }
local severity_map = {
  ["error"] = vim.diagnostic.severity.ERROR,
  ["warning"] = vim.diagnostic.severity.WARN,
}

return {
  cmd = "ghdl",
  stdin = false,
  args = { "-s", "--std=08" },
  stream = "stderr",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severity_map, {
    source = "ghdl",
  }),
}
