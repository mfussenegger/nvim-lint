return {
  cmd = 'statix',
  stdin = true,
  args = {'check', '-o', 'errfmt', '--stdin'},
  stream = 'stdout',
  ignore_exitcode = true, -- statix only returns 0 if there are no errors
  parser = require('lint.parser').from_errorformat('%f>%l:%c:%t:%n:%m', {
    source = 'statix'
  })
}
