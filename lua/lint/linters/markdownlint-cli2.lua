local efm = "%f:%l:%c %m,%f:%l %m"
return {
  cmd = "markdownlint-cli2",
  ignore_exitcode = true,
  stream = "stderr",
  parser = require("lint.parser").from_errorformat(efm, {
    source = "markdownlint",
    severity = vim.diagnostic.severity.WARN,
  }),
}
