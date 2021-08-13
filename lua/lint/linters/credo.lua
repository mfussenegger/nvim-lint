return {
  cmd = 'mix credo',
  args = { '--strict' },
  ignore_exitcode = false,
  parser = require('lint-parser').from_errorformat('%f:%l: %m', {
    source = 'mix credo',
    severity = vim.lsp.protocol.DiagnosticSeverity.Information
  })
}
