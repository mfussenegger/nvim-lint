return {
  cmd = "systemd-analyze",
  args = {"verify"},
  ignore_exitcode = true,
  stdin = false,
  stream = "stderr",
  parser = require("lint.parser").from_errorformat("%f:%l:%m", {
    source = "systemd",
    severity = vim.diagnostic.severity.WARN
  })
}
