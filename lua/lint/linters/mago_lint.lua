local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  note = vim.diagnostic.severity.INFO,
  help = vim.diagnostic.severity.HINT,
}

local pattern = '[^:]+:(%d+):(%d+):%s?(%l+)%[([%w-]+)%]:%s?(.+)'
local groups = { 'lnum', 'col', 'severity', 'code', 'message' }

return {
  cmd = "mago",
  args = { "--colors=never", "lint", "--reporting-format=short" },
  append_fname = true,
  stdin = false,
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(
    pattern,
    groups,
    severities,
    { ['source'] = 'mago_lint' }
  ),
}
