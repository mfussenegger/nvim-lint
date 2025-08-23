local pattern = "::([^ ]+) file=(.*),line=(%d+),endLine=(%d+),col=(%d+),endColumn=(%d+),title=(.*)::(.*)"
local severities = {
  ["error"] = vim.diagnostic.severity.ERROR,
  ["warning"] = vim.diagnostic.severity.WARN,
}
local groups = { "severity", "file", "lnum", "end_lnum", "col", "end_col", "code", "message" }
local defaults = { ["source"] = "oxlint" }
local binary_name = "oxlint"

return {
  cmd = function()
    local local_binary = vim.fn.fnamemodify("./node_modules/.bin/" .. binary_name, ":p")
    return vim.loop.fs_stat(local_binary) and local_binary or binary_name
  end,
  stdin = false,
  args = { "--format", "github" },
  stream = "stdout",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severities, defaults, {}),
}
