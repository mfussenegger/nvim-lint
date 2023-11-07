local pattern = '(.+):(%d+):(%d+):(%l+):(.+):(.+)'
local groups = { 'file', 'lnum', 'col', 'severity', 'code', 'message' }

severities = {
  ['error'] = vim.diagnostic.severity.ERROR,
  ['warning'] = vim.diagnostic.severity.WARN,
}

return {
  cmd = 'puppet-lint',
  stdin = false,
  args = {
    '--no-autoloader_layout-check',
    '--log-format', '%{path}:%{line}:%{column}:%{kind}:%{check}:%{message}'
  },
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, severities, {
    ['source'] = 'puppet-lint',
  }),
}
