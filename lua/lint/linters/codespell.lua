-- stdout output in the form "63: resourcs ==> resources, resource"
local pattern = "(%d+): (.*)"
local groups = { "lnum", "message" }
local severities = nil -- none provided

return {
  cmd = 'codespell',
  args = { '--stdin-single-line', "-" },
  stdin = true,
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, severities, {
    source = 'codespell',
    severity = vim.diagnostic.severity.INFO,
  }),
}
