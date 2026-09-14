return {
  name = "refurb",
  cmd = "refurb",
  stdin = false,
  append_fname = true,
  args = { "--quiet" },
  stream = "stdout",
  ignore_exitcode = true,
  env = nil,
  parser = require("lint.parser").from_pattern(
    "^([^:]+):(%d+):(%d+)%s+%[([^%]]+)%]:%s*(.*)$",
    { "file", "lnum", "col", "code", "message" },
    nil,
    { ["severity"] = vim.diagnostic.severity.INFO }
  ),
}
