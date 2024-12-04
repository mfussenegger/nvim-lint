local binary_name = "ts-standard"
local pattern = "[^:]+:(%d+):(%d+):([^%.]+%.?)%s%(([%a-]+)%)%s?%(?(%a*)%)?"
local groups = { "lnum", "col", "message", "code", "severity" }
local severities = {
  [""] = vim.diagnostic.severity.ERROR,
  ["warning"] = vim.diagnostic.severity.WARN,
}

return {
  cmd = function()
    local local_binary = vim.fn.fnamemodify("./node_modules/.bin/" .. binary_name, ":p")
    return vim.loop.fs_stat(local_binary) and local_binary or binary_name
  end,
  stdin = true,
  args = { "--stdin" },
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severities, { ["source"] = "ts-standard" }, {}),
}
