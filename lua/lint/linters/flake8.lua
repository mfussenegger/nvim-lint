-- path/to/file:line:col: code message
local pattern = "[^:]+:(%d+):(%d+):(%w+):(.+)"

return {
  cmd = 'flake8',
  stdin = false,
  args = {
    '--format=%(path)s:%(row)d:%(col)d:%(code)s:%(text)s',
    '--no-show-source',
  },
  parser = require('lint.parser').from_pattern(
    pattern,
    {
      source = 'flake8',
      severity = vim.lsp.protocol.DiagnosticSeverity.Error
    }
  )
}
