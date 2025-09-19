return {
  cmd = 'python3',
  args = {'-m', 'json.tool'},
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat('%m: line %l column %c (char %r)', {
    source = 'json.tool'
  })
}
