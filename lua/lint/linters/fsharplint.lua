return {
  name = 'fsharplint',
  cmd = 'dotnet-fsharplint',
  args = { '--format', 'msbuild', 'lint' },
  stdin = false,
  append_fname = true,
  stream = 'stdout',
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat(
    [[%f(%.%#\,%.%#\,%l\,%c):FSharpLint\ %tarning %m]],
    {
      source = 'fsharplint',
      severity = vim.diagnostic.severity.WARN,
    }
  ),
}
