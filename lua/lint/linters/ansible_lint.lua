return {
  cmd = 'ansible-lint',
  args = { '-p' },
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat('%f:%l: %m', {
    source = 'ansible-lint',
    severity = require('lint').default_severity,
  })
}
