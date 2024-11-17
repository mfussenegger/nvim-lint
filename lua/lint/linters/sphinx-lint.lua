local efm = '%f:%l: %m'

return {
  cmd = 'sphinx-lint',

  stream = 'stderr',
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat(efm, {
    source = 'sphinx-lint',
    severity = vim.diagnostic.severity.WARN,
  }),
}
