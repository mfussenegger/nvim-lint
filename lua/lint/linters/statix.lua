return {
  cmd = 'statix',
  stdin = false,
  args = {'check', '-o', 'errfmt', '--'},
  stream = 'stderr',
  parser = require('lint.parser').from_errorformat('%f>%l:%c:%t:%n:%m', {
    source = 'statix'
  })
}
