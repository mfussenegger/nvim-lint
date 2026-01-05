local efm = "stdin:%l:%c %m,stdin:%l %m"
return {
  cmd = "markdownlint-cli2",
  stdin = true,
  args = { "-" },
  ignore_exitcode = true,
  stream = "stderr",
  parser = require("lint.parser").from_errorformat(efm, {
    source = "markdownlint",
    severity = vim.diagnostic.severity.WARN,
  }),
}
