-- Look for patterns like the following:
--
-- vuln.c:6:3:  [5] (buffer) gets:Does not check for buffer overflows (CWE-120, CWE-20).  Use fgets() instead.

local pattern = [[^(.*):(\d+):(\d+): *\[([0-5])\] (.*)$]]
local groups = { 'file', 'line', 'start_col', 'severity', 'message' }

local DiagnosticSeverity = vim.lsp.protocol.DiagnosticSeverity

local severity_map = {
  ['5'] = DiagnosticSeverity.Warning,
  ['4'] = DiagnosticSeverity.Warning,
  ['3'] = DiagnosticSeverity.Warning,
  ['2'] = DiagnosticSeverity.Warning,
  ['1'] = DiagnosticSeverity.Warning,
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
