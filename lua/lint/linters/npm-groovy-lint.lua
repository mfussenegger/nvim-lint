local pattern = "^%s+(%d+)%s+[^a-z]+m([a-z]+)[^a-z]+m%s+(.*)%s+(%w+)"
local groups = { "lnum", "severity", "message", "code" }
local severity_map = {
  ["info"] = vim.diagnostic.severity.INFO,
  ["warning"] = vim.diagnostic.severity.WARN,
  ["error"] = vim.diagnostic.severity.ERROR,
}

return {
  cmd = "npm-groovy-lint",
  stdin = false,
  parser = require("lint.parser").from_pattern(pattern, groups, severity_map, { ["source"] = "npm-groovy-lint" }),
}
