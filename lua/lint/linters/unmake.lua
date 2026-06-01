---@type lint.Linter
return {
  name = 'unmake',
  cmd = 'unmake',
  stdin = false,
  stream = 'stdout',
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(
    '(%w+): (.-):(%d*):?(%d*): (.+)',
    { 'severity', 'file', 'lnum', 'column', 'message' },
    {
      error = vim.diagnostic.severity.ERROR,
      warning = vim.diagnostic.severity.WARN,
      info = vim.diagnostic.severity.INFO,
      hint = vim.diagnostic.severity.HINT,
    },
    { ['source'] = 'unmake', }
  ),
}
