local stdin = not vim.loop.os_uname().version:match("Windows")

local args = {
  "--no-exec",
  "--no-rcs",
  "--no-globalrcs",
}
if stdin then
  table.insert(args, "/dev/stdin")
end

return {
  cmd = "zsh",
  stdin = stdin,
  ignore_exitcode = true,
  args = args,
  stream = "stderr",
  parser = require("lint.parser").from_errorformat("%s:%l:%m", {
    source = "zsh",
    severity = vim.diagnostic.severity.ERROR,
  }),
}
