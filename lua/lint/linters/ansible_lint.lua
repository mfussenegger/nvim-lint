return {
  cmd = 'ansible-lint',
  args = { '-p', '--nocolor' },
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat('%f:%l: %m', {
    source = 'ansible-lint',
    severity = vim.diagnostic.severity.INFO
  })
}
