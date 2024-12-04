-- Lint Errors
--  <text>:2:3: Unexpected var, use let or const instead. (no-var) (warning)
--  <text>:3:13: Expected '===' and instead saw '=='. (eqeqeq)
--  <text>:4:14: Strings must use singlequote. (quotes)
--  <text>:4:20: Extra semicolon. (semi)
--  <text>:6:4: Extra semicolon. (semi)
--  <text>:8:18: Extra semicolon. (semi)
--  <text>:9:5: Extra semicolon. (semi)
--
-- Parsing Error
--  /home/jorge/code/index.js:2:13: Parsing error: Unexpected token 1 (null)

local binary_name = "standard"
local pattern = "[^:]+:(%d+):(%d+):([^%.]+%.?)%s%(([%a-]+)%)%s?%(?(%a*)%)?"
local groups = { 'lnum', 'col', 'message', 'code', 'severity' }
local severities = {
  [''] = vim.diagnostic.severity.ERROR,
  ['warning'] = vim.diagnostic.severity.WARN
}

return {
  cmd = function()
    local local_binary = vim.fn.fnamemodify('./node_modules/.bin/' .. binary_name, ':p')
    return vim.loop.fs_stat(local_binary) and local_binary or binary_name
  end,
  stdin = true,
  args = { "--stdin" },
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(
    pattern,
    groups,
    severities,
    { ['source'] = 'standardjs' },
    {}
  )
}
