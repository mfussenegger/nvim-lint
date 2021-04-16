-- path/to/file:line:col: code message
local pattern = "[^:]+:(%d+):(%d+): (%w+) (.*)"

return {
  cmd = 'flake8',
  stdin = false,
  args = {},
  parser = require('lint.parser').from_pattern(
    pattern,
    {
      source = 'flake8',
      severity = vim.lsp.protocol.DiagnosticSeverity.Error
    }
  )
}
