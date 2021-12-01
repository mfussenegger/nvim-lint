return {
  cmd = 'pydocstyle',
  stdin = false,
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat(
    '%N%f:%l%.%#,%Z%s%#D%n: %m',
    {source = 'pydocstyle'}
  ),
}
