return {
  cmd = 'bean-check',
  stdin = false,
  stream = 'stderr',
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat('%f:%l: %m', {
    source = 'bean-check',
    severity = vim.diagnostic.severity.ERROR,
  })
}
