return {
  cmd = 'jsonlint',
  stream = 'stderr',
  args = { '--compact' },
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat("%f:\\ line\\ %l\\,\\ col\\ %c\\, %m", {
    source = 'jsonlint',
    severity = vim.diagnostic.severity.ERROR,
  })
}
