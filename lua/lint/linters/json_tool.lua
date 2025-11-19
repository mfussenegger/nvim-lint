return {
  cmd = "python3",
  args = {"-m", "json.tool"},
  stdin = true,
  stream = "stderr",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(
    "^(.+): line (%d+) column (%d+) .+",
    { "message", "lnum", "col" },
    nil,
    nil,
    { lnum_offset = -1 }
  ),
}
