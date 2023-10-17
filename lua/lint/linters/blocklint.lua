return {
  cmd = "blocklint",
  args = { "--stdin", "--end-pos" },
  stdin = true,
  parser = require("lint.parser").from_errorformat("stdin:%l:%c:%k: %m", {
    source = "blocklint",
    severity = vim.diagnostic.severity.INFO,
  }),
}
