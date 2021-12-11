local pattern = [[([^:]*):(%d+):(%d+): (%w+): ([^[]+)]]
local groups = { 'file', 'lnum', 'col', 'severity', 'message' }

local severity_map = {
  ['error'] = vim.diagnostic.severity.ERROR,
  ['warning'] = vim.diagnostic.severity.WARN,
  ['information'] = vim.diagnostic.severity.INFO,
  ['hint'] = vim.diagnostic.severity.HINT,
  ['note'] = vim.diagnostic.severity.HINT,
}

return {
  cmd = 'clang-tidy',
  stdin = false,
  args = { '--quiet' },
  parser = require('lint.parser').from_pattern(pattern, groups, severity_map, { ['source'] = 'clang-tidy' }),
}
