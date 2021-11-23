return {
  cmd = 'jshint',
  stdin = false,
  args = {'--verbose'},
  stream = 'stdout',
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat('%f: line %l\\, col %c\\, %m', {
    source = 'jshint',
    severity = vim.lsp.protocol.DiagnosticSeverity.Warning,
  })
}
