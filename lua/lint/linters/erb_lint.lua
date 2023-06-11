local efm = '%f:%l:%c: %m'

return {
  cmd = 'bundle',
  args = { 'exec', 'erblint', '--format', 'compact' },
  stream = 'stdout',
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat(efm, {
    source = 'erb-lint',
    severity = vim.diagnostic.severity.WARN
  })
}

