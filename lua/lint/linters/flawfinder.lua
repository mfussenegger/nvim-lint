-- Look for patterns like the following:
--
-- vuln.c:6:3:  [5] (buffer) gets:Does not check for buffer overflows (CWE-120, CWE-20).  Use fgets() instead.

local pattern = [[^(.*):(%d+):(%d+): *%[([0-5])%] (.*)$]]
local groups = { 'file', 'lnum', 'col', 'severity', 'message' }

local severity_map = {
  ['5'] = vim.diagnostic.severity.WARN,
  ['4'] = vim.diagnostic.severity.WARN,
  ['3'] = vim.diagnostic.severity.WARN,
  ['2'] = vim.diagnostic.severity.WARN,
  ['1'] = vim.diagnostic.severity.WARN,
}

return {
  cmd = 'flawfinder',
  stdin = false,
  args = {'-S', '-Q', '-D', '-C', '--'},
  stream = 'stdout',
  parser = require('lint.parser').from_pattern(pattern, groups, severity_map, {
    ['source'] = 'flawfinder'
  })
}
