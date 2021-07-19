local pattern = '[^:]+:(%d+):(%d+)-(%d+): %((%a)(%d+)%) (.*)'
local groups = { 'line', 'start_col', 'end_col', 'severity', 'code', 'message' }
local severities = {
  W = vim.lsp.protocol.DiagnosticSeverity.Warning,
  E = vim.lsp.protocol.DiagnosticSeverity.Error,
}

return {
  cmd = 'luacheck',
  stdin = true,
  args = { '--formatter', 'plain', '--codes', '--ranges', '-' },
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, severities, { ['source'] = 'luacheck' }),
}
