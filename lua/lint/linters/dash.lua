local pattern = "(.+): (%d+): (.+)"
local groups = { "file", "lnum", "message" }

return {
  cmd = "dash",
  stdin = false,
  ignore_exitcode = true,
  args = { "-n" },
  stream = "stderr",
  parser = require("lint.parser").from_pattern(pattern, groups, nil, {
    ["source"] = "dash",
    ["severity"] = vim.diagnostic.severity.ERROR,
  }),
}
