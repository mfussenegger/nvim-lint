local errorformat = '%f:%l:%c:%tarning:%m, %f:%l:%c:%trror:%m'

return {
  cmd = 'puppet-lint',
  stdin = false,
  args = {
    '--no-autoloader_layout-check',
    '--log-format', '%{path}:%{line}:%{column}:%{kind}:[%{check}] %{message}'
  },
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat(errorformat, {
    source = 'puppet-lint',
  })
}
