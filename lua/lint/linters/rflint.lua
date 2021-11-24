return {
  cmd = 'rflint',
  stdin = false,
  args = {'--format', '{filename}:{severity}:{linenumber}:{char}:{message}'},
  stream = 'stdout',
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat('%f:%t:%l:%c:%m', {
    source = 'rflint'
  })
}
