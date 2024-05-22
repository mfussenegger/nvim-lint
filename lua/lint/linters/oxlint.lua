return {
  cmd = "oxlint",
  stdin = false,
  args = { "--format", "unix" },
  stream = "stdout",
  ignore_exitcode = true,
  parser = require("lint.parser").from_errorformat("%f:%l:%c: %m", {
    source = "oxlint",
    severity = vim.diagnostic.severity.WARN,
  }),
}
