return {
  cmd = "detekt",
  stdin = false,
  args = { "-bp " },
  stream = "stdout",
  ignore_exitcode = false,
  parser = require("lint.parser").from_pattern(
    "([^:]+):(%d+):(%d+): ([^[]+) %[(.+)%]",
    { "file", "lnum", "col", "message", "rule" },
    nil,
    {
      ["source"] = "detekt",
      ["severity"] = vim.diagnostic.severity.WARN,
    }
  ),
}
