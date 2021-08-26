local pattern = '^(%w+): (.+) at .+:(%d+):(%d+)$'
local groups = { 'severity', 'message', 'line', 'start_col' }
local severity_map = { error = vim.lsp.protocol.DiagnosticSeverity.Error }

return {
  cmd = 'nix-instantiate',
  stdin = true,
  args = {
    '--parse',
    '-',
  },
  stream = 'stderr',
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, severity_map, {
    ['source'] = 'nix',
    ['severity'] = vim.lsp.protocol.DiagnosticSeverity.Warning,
  })
}
