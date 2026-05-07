local function get_file_name()
  return vim.api.nvim_buf_get_name(0)
end

local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  info = vim.diagnostic.severity.INFO,
}

local pattern = "^(%w+)%[([%w%-_]+)%]:%s+(.-) at .-:(%d+):(%d+)$"
local groups = { "severity", "code", "message", "lnum", "col" }
local defaults = { source = "panache" }

return {
  cmd = "panache",
  stdin = true,
  args = {
    "lint",
    "--message-format",
    "short",
    "--no-color",
    "--stdin-filename",
    get_file_name,
  },
  stream = "stdout",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severities, defaults),
}
