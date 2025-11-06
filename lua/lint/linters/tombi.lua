local efm = "%E  Error: %m,%WWarning: %m,%C    at %f:%l:%c"

return {
  cmd = "tombi",
  args = { "lint" },
  stdin = false,
  stream = "stdout",
  ignore_exitcode = true,
  env = {
    ["NO_COLOR"] = "1", -- Any non-empty value disables colored output
  },
  parser = require("lint.parser").from_errorformat(efm, { source = "tombi" }),
}
