-- The scripts/ directory of the Linux kernel tree needs to be in your PATH or
-- the full path to the checkpatch.pl script can be overriden from user config:
-- require("lint").linters.checkpatch.cmd = '…/checkpatch.pl'

-- path/to/file:line: severity: message
local pattern = '([^:]+):(%d+): (%a+): (.+)'
local groups = { 'file', 'lnum', 'severity', 'message' }
local severity_map = {
  ['ERROR'] = vim.diagnostic.severity.ERROR,
  ['WARNING'] = vim.diagnostic.severity.WARN,
  ['CHECK'] = vim.diagnostic.severity.INFO,
}

return {
  cmd = 'checkpatch.pl',
  stdin = false,
  args = {
    '--strict',
    '--terse',
    '--file',
  },
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(
    pattern, groups, severity_map,
    { ['source'] = 'checkpatch' }
  ),
}
