return {
  cmd = "dotenv-linter",
  stdin = false,
  args = { "check", "--quiet" },
  stream = "stdout",
  ignore_exitcode = true,
  env = nil,

  parser = require("lint.parser").from_pattern(
    [=[%w+:(%d+) (%w+): (.*)]=],
    { "lnum", "code", "message" },
    nil,
    { ["source"] = "dotenv_linter", ["severity"] = vim.diagnostic.severity.INFO }
  ),
}
