return {
  cmd = "jq",
  stdin = true,
  stream = "stderr",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(
    "^(.+): (.+) at line (%d+), column (%d+)$",
    { "code", "message", "lnum", "col" },
    nil,
    nil,
    { lnum_offset = -1 }
  ),
}
