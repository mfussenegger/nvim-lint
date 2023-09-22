local pattern = "%s*(%d+): (.+)"
local groups = { "lnum", "message" }

return {
  cmd = "editorconfig-checker",
  stdin = false,
  ignore_exitcode = true,
  args = { "-no-color" },
  parser = require("lint.parser").from_pattern(
    pattern,
    groups,
    nil,
    { severity = vim.diagnostic.severity.INFO, source = "editorconfig-checker" }
  ),
}
