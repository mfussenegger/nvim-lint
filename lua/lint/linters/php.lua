local efm = table.concat({
  'Deprecated:\\ %m\\ %tn\\ Standard\\ input\\ code\\ on\\ line\\ %l', -- nasty hack for %t
  '%tarning:\\ %m\\ in\\ Standard\\ input\\ code\\ on\\ line\\ %l',
  'Parse\\ %trror:\\ %m\\ in\\ Standard\\ input\\ code\\ on\\ line\\ %l',
  'Fatal\\ %trror:\\ %m\\ in\\ Standard\\ input\\ code\\ on\\ line\\ %l',
}, ',')

return {
  cmd = 'php',
  stdin = true,
  args = {
    -- '-d error_reporting=-1',
    '-d display_errors=stdout',
    '-l',
  },
  stream = 'stdout',
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat(efm, {
    source = 'php'
  })
}
