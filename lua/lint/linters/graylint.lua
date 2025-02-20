local severities = {
  E = vim.diagnostic.severity.ERROR, -- Error
  F = vim.diagnostic.severity.ERROR, -- Fatal
  W = vim.diagnostic.severity.WARN, -- Warning
  R = vim.diagnostic.severity.INFO, -- Refactor
  I = vim.diagnostic.severity.INFO, -- Info
  C = vim.diagnostic.severity.HINT, -- Convention
}
local pattern = "^(.*):([0-9]+):([0-9]+):%s*([A-Z])([0-9]+):%s*(.*)%s*$"
local groups = { "file", "lnum", "col", "severity", "code", "message" }
local defaults = { source = "graylint" }
local opts = { col_offset = 0 }

return {
  cmd = "graylint",
  args = {
    "--lint",
    "pylint",
  },
  stdin = false,
  stream = "stdout",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severities, defaults, opts),
}
