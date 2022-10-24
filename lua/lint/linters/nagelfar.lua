local pattern = '%f: %l: %t %m,%-GChecking file %f'

return {
  cmd             = 'nagelfar',
  args            = {'-H'},
  append_fname    = true,
  stdin           = false,
  stream          = 'both',
  ignore_exitcode = true,
  env             = nil,
  parser          = require('lint.parser').from_errorformat(pattern)
}
