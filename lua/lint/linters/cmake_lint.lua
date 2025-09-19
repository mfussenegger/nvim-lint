return {
  cmd = 'cmake-lint',
  args = {'--quiet'},
  stdin = false,
  parser = require('lint.parser').from_errorformat('%f:%l,%c: %m', {
    source = 'cmake-lint'
  })
}
