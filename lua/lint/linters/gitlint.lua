local pattern = "^(%d+): (%w+) (.*)$"
local groups = { "lnum", "code", "message" }

return {
  cmd = "gitlint",
  stdin = false,
  args = { "--staged", "--msg-filename" },
  append_fname = true,
  stream = "stderr",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups),
}
