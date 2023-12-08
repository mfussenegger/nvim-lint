return {
  cmd = "joker",
  stdin = false,
  stream = "stderr",
  args = { "--lint" },
  ignore_exitcode = true,
  parser = require("lint.parser").from_errorformat("%f:%l:%c: %m", {
    source = "joker",
  }),
}
