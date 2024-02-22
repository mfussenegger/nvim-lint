local pattern = [[([^:]*):(%d+):(%d+): ([^[]+)]]
local groups = { 'file', 'lnum', 'col', 'message'}

return {
  cmd = "ponyc",
  stdin = false,
  append_fname = false,
  args = { "--pass=verify" },
  stream = "stderr",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, nil, {
      ["source"] = "ponyc",
      ["severity"] = vim.diagnostic.severity.ERROR,
    }),
}
