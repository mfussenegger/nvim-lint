return {
  cmd = "woke",
  args = { "--stdin", "--output=simple" },
  stdin = true,
  parser = require("lint.parser").from_errorformat(
    "/dev/stdin:%l:%c: [%tarning] %m,/dev/stdin:%l:%c: [%trror] %m",
    { source = "woke", severity = vim.diagnostic.severity.INFO }
  ),
}
