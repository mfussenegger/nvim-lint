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
  local current_file = vim.api.nvim_buf_get_name(0)
  local dir = current_file ~= '' and vim.fs.dirname(current_file) or vim.fn.getcwd()

  -- FIXME: switch to using vim.fs.root() once minimal version is bumped to 0.10.
  local git_dir = vim.fs.find('.git', {
    path = dir,
    upward = true,
    type = 'directory',
    limit = 1,
  })[1]

  if git_dir then
    local project_root = vim.fs.dirname(git_dir)
    local tool_path = vim.fs.joinpath(project_root, 'scripts', tool_name)
    if vim.fn.executable(tool_path) == 1 then
      return tool_path
    end
  end

  if vim.fn.executable(tool_name) == 1 then
    return tool_name
  end

  -- If checkpatch executable is not found return "true" which is a valid command
  -- that will not produce any diagnostic but return success error code. This will
  -- allow enabling checkpatch linter globally and only return diagnostic if
  -- a project is actually using it.
  return "true"
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
