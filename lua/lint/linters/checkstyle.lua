local format = '[%tRROR] %f:%l: %m, [%tRROR] %f:%l:%c: %m, [%tARN] %f:%l:%c: %m, [%tARN] %f:%l: %m'

return {
  cmd = 'checkstyle',
  args = { '-p' },
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat(format, {
    source = 'checkstyle',
    severity = vim.lsp.protocol.DiagnosticSeverity.Information
  })
}
