-- This favors the version of `checkpatch.pl` supplied by the project
-- to which the file being linted belongs, falling back to a version
-- accessible via `$PATH`. If a user wishes to use a different version
-- of the script they can override "cmd" in their config:
-- require("lint").linters.checkpatch.cmd = '…/checkpatch.pl'

local tool_name = 'checkpatch.pl'

-- path/to/file:line: severity: message
local pattern = '([^:]+):(%d+): (%a+): (.+)'
local groups = { 'file', 'lnum', 'severity', 'message' }
local severity_map = {
  ['ERROR'] = vim.diagnostic.severity.ERROR,
  ['WARNING'] = vim.diagnostic.severity.WARN,
  ['CHECK'] = vim.diagnostic.severity.INFO,
}

local function locate_checkpatch()
  local tool_path = vim.fs.joinpath(vim.fn.getcwd(), 'scripts', tool_name)
  if vim.fn.executable(tool_path) == 1 then
    return tool_path
  end

  if vim.fn.executable(tool_name) == 1 then
    return tool_name
  end

  -- If checkpatch executable is not found return "true" which is a valid command
  -- that will not produce any diagnostic but return success error code. This will
  -- allow enabling checkpatch linter globally and only return diagnostic if
  -- a project is actually using it.
  return 'true'
end

return {
  cmd = locate_checkpatch,
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
