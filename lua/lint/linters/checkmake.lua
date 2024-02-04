local pattern = "(%d+):(%w+):(.+)"
local groups = { "lnum", "code", "message" }

return {
  cmd = "checkmake",
  stdin = false,
  append_fname = true,
  args = {
    "--format='{{.LineNumber}}:{{.Rule}}:{{.Violation}}\n'",
  },
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, nil, {
    ["source"] = "checkmake",
    ["severity"] = vim.diagnostic.severity.WARN,
  }),
}
