local errorfmt = '[%t] %. %f:%l:%c %m, [%t] %. %f:%l %m'

return {
  cmd = 'mix',
  stdin = true,
  args = { 'credo', 'list', '--format=oneline', '--read-from-stdin', '--strict'},
  stream = 'stdout',
  ignore_exitcode = true, -- credo only returns 0 if there are no errors
  parser = require('lint.parser').from_errorformat(errorfmt, { ['source'] = 'credo' })
}


