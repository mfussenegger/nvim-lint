return {
  cmd = "bash",
  stdin = true,
  append_fname = false,
  args = { "-n", "-s" },
  stream = "stderr",
  ignore_exitcode = true,
  parser = require("lint.parser").from_errorformat("bash:\\ line\\ %l:\\ %m", {
    source = "bash",
    severity = vim.diagnostic.severity.ERROR,
  }),
}
