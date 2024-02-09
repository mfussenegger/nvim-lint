local efm = "%E%m:,%C%f:%l:%c"

return {
  cmd = "cue",
  args = { "vet" },
  stdin = false,
  ignore_exitcode = true,
  stream = "stderr",
  parser = require("lint.parser").from_errorformat(efm, {
    source = "cue vet",
  }),
}
