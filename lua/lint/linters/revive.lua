-- path/to/file:line:col: code message
local pattern = "[^:]+:(%d+):(%d+): (%w+) (.*)"

return {
  cmd = 'revive',
  stdin = false,
  args = {},
  parser = require('lint.parser').from_pattern(
    pattern,
    {
      source = 'revive',
      severity = vim.lsp.protocol.DiagnosticSeverity.Warning,
    }
  )
}
