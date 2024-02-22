local pattern = '.*: line (%d+), col (%d+), (%a+) %- (.+) %((.+)%)'
local groups = { 'lnum', 'col', 'severity', 'message', 'code' }
local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
}

return {
  cmd = "htmlhint",
  stdin = true,
  args = {
    "stdin",
    "-f",
    "compact",
  },
  stream = "stdout",
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(
    pattern,
    groups,
    severities,
    { source = "htmlhint" }
  )
}
