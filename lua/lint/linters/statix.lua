return {
  cmd = 'statix',
  stdin = true,
  args = {'check', '-o', 'errfmt', '--stdin'},
  stream = 'stdout',
  parser = require('lint.parser').from_errorformat('%f>%l:%c:%t:%n:%m', {
    source = 'statix'
  })
}
