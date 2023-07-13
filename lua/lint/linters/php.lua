local efm=''
efm = efm..'Deprecated:\\ %m\\ %tn\\ Standard\\ input\\ code\\ on\\ line\\ %l' -- nasty hack for %t
efm = efm..',%tarning:\\ %m\\ in\\ Standard\\ input\\ code\\ on\\ line\\ %l'
efm = efm..',Parse\\ %trror:\\ %m\\ in\\ Standard\\ input\\ code\\ on\\ line\\ %l'
efm = efm..',Fatal\\ %trror:\\ %m\\ in\\ Standard\\ input\\ code\\ on\\ line\\ %l'

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
