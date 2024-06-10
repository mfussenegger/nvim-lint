local pattern = "([^:]+):(%d+):(%d+):(.+)"
local groups = { "file", "lnum", "col", "message" }
local severity_map = {
  ["error"] = vim.diagnostic.severity.ERROR,
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
