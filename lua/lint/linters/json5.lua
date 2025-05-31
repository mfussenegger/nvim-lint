return {
  cmd = 'json5',
  stdin = true,
  append_fname = false,
  args = { '--validate' },
  stream = 'stderr',
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat('JSON5:\\ %m\\ at\\ %l:%c', {
    source = 'json5',
    severity = vim.diagnostic.severity.ERROR,
  }),
}
