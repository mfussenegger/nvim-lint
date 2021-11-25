return {
  cmd = 'robocop',
  stdin = false,
  args = {'--format', '{source}:{line}:{col}:{severity}:{rule_id}:{desc}'},
  stream = 'stdout',
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat('%f:%l:%c:%t:%n:%m', {
    source = 'robocop'
  })
}
