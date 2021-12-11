return {
  cmd = 'jshint',
  stdin = false,
  args = {'--reporter', 'unix', '--extract', 'auto'},
  stream = 'stdout',
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat('%f:%l:%c: %m', {
    source = 'jshint',
    severity = vim.diagnostic.severity.WARN,
  })
}
