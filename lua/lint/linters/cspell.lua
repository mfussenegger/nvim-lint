return {
  cmd = 'cspell',
  stdin = true,
  args = {
    'lint',
    '--no-color',
    '--no-progress',
    '--no-summary',
    '--',
    'stdin'
  },
  stream = 'stdout',
  parser = require('lint.parser').from_errorformat('/:%l:%c - %m', {
    source = 'cspell',
    severity = vim.diagnostic.severity.INFO
  })
}
