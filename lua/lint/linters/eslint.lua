local function get_root (...)
  local root_dir = require'lspconfig/util'.root_pattern(...)
  local cwd = vim.fn.getcwd()
  return root_dir(cwd)
end

local pattern = [[%s*(%d+):(%d+)%s+(%w+)%s+(.+%S)%s+(%S+)]]
local groups = { 'line', 'start_col', 'severity', 'message', 'code' }
local severity_map = {
  ['error'] = vim.lsp.protocol.DiagnosticSeverity.Error,
  ['warn'] = vim.lsp.protocol.DiagnosticSeverity.Warning,
}

local root_dir = get_root('package.json')

return {
  cmd = {root_dir .. '/node_modules/eslint/bin/eslint.js', 'eslint'},
  args = {'--stdin'},
  stdin = true,
  stream = 'stdout',
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(pattern, groups, severity_map, { ['source'] = 'eslint' }),
}
