
return {
  cmd = 'codespell',
  stdin = false,
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat(
    '%f:%l:%m',
    { severity = vim.lsp.protocol.DiagnosticSeverity.Information }
  )
}
