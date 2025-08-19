local efm = '%f:%l:%c: %m,%f:%l: %m'
return {
  cmd = 'ansible-lint',
  args = { '-p', '--nocolor' },
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat(efm, {
    source = 'ansible-lint',
    severity = vim.diagnostic.severity.INFO
  })
}
