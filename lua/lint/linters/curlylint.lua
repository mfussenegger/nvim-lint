local efm = '%f:%l:%c: %m'
return {
  cmd = 'curlylint',
  args = {'--format', 'compact'},
  stdin = false,
  stream = 'stdout',
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat(efm, {
    source = 'curlylint',
    severity = vim.diagnostic.severity.WARN
  })
}
