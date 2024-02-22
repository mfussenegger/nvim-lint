local pattern = "^(%d+): (%w+) (.*)$"
local groups = { "lnum", "code", "message" }

return {
  cmd = "gitlint",
  stdin = true,
  args = {
    "--staged",
    "--msg-filename",
    function() return vim.api.nvim_buf_get_name(0) end
  },
  stream = "stderr",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups),
}
