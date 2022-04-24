local efm = "%E%f (line %l): %m,%C%p^,%C%.%#"
return {
  cmd = "fish",
  args = { "--no-execute" },
  stdin = false,
  ignore_exitcode = true,
  stream = "stderr",
  parser = require("lint.parser").from_errorformat(efm, {
    source = "fish",
    severity = vim.diagnostic.severity.ERROR,
  }),
}
