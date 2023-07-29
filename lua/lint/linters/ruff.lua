-- path/to/file:line:col: code message
local pattern = '[^:]+:(%d+):(%d+): (%w+) (.+)'
local groups = { 'lnum', 'col', 'code', 'message' }
local function get_file_name()
  return vim.api.nvim_buf_get_name(0)
end

return {
  cmd = 'ruff',
  stdin = true,
  args = {
    '--force-exclude',
    '--quiet',
    '--stdin-filename',
    get_file_name,
    '--no-fix',
    '-',
  },
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, nil, {
    ['source'] = 'ruff',
    ['severity'] = vim.diagnostic.severity.WARN,
  }),
}
