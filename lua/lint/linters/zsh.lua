return {
  cmd = "zsh",
  stdin = false,
  ignore_exitcode = true,
  args = { "--no-exec" },
  stream = "stderr",
  parser = require("lint.parser").from_errorformat("%f:%l:%m", {
    source = "zsh",
    severity = vim.diagnostic.severity.ERROR,
  }),
}
