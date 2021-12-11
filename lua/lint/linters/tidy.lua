local pattern = 'line (%d+) column (%d+) %- (%a+): (.+)'
local groups = { 'lnum', 'col', 'severity', 'message' }
local severities = {
  Info = vim.diagnostic.severity.INFO,
  Warning = vim.diagnostic.severity.WARN,
  Config = vim.diagnostic.severity.ERROR,
  Access = vim.diagnostic.severity.INFO,
  Error = vim.diagnostic.severity.ERROR,
  Document = vim.diagnostic.severity.ERROR,
  Panic = vim.diagnostic.severity.ERROR,
  Summary = vim.diagnostic.severity.INFO,
  Information = vim.diagnostic.severity.INFO,
  Footnote = vim.diagnostic.severity.INFO,
}

return {
  cmd = 'tidy',
  stdin = true,
  stream = 'stderr',
  args = {
    '-quiet',
    '-errors',
    '-language',
    'en',
    '--gnu-emacs',
    'yes',
  },
  parser = require('lint.parser').from_pattern(pattern, groups, severities, { ['source'] = 'tidy' }),
}
