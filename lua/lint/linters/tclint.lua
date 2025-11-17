local pattern = "[^:]+:(%d+):(%d+): (.+) %[([^%]]+)%]"
local groups = { "lnum", "col", "message", "code" }

return {
  cmd = "tclint",
  stdin = true,
  args = { "-" },
  stream = "stdout",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(
    pattern,
    groups,
    nil,
    { source = "tclint" }
  ),
}
