local pattern = [[%s*(%d+):(%d+)%s+(%w+)%s+(.+%S)%s+(%S+)]]
local groups = { 'lnum', 'col', 'severity', 'message', 'code' }
local severity_map = {
  ['error'] = vim.diagnostic.severity.ERROR,
  ['warn'] = vim.diagnostic.severity.WARN,
  ['warning'] = vim.diagnostic.severity.WARN,
}

return require('lint.util').inject_cmd_exe({
  cmd = function()
    local local_eslintd = vim.fn.fnamemodify('./node_modules/.bin/eslint_d', ':p')
    local stat = vim.loop.fs_stat(local_eslintd)
    if stat then
      return local_eslintd
    end
    return 'eslint_d'
  end,
  args = {},
  stdin = false,
  stream = 'stdout',
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, severity_map, { ['source'] = 'eslint_d' }),
})
