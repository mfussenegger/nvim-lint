local pattern = '(%d+):(%d+):(%w+) (.+)'
local groups = { 'lnum', 'col', 'severity', 'message' }
local severity_map = {
  ['1'] = vim.diagnostic.severity.HINT,
  ['2'] = vim.diagnostic.severity.INFO,
  ['3'] = vim.diagnostic.severity.WARN,
  ['4'] = vim.diagnostic.severity.WARN,
  ['5'] = vim.diagnostic.severity.ERROR,
}

local find_conf = function()
  local conf = vim.fs.find('.perlcriticrc', {
    upward = true,
    stop = vim.fs.dirname(vim.uv.os_homedir()),
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
  })
  return conf[1] or ''
end

return function()
  local profile = find_conf()
  return {
    cmd = 'perlcritic',
    stdin = true,
    args = { '--nocolor', '--verbose', '%l:%c:%s %m [%p]\n', '--profile', profile },
    stream = 'stdout',
    ignore_exitcode = true, -- returns 2 if policy violations are found, but 1 if perlcritic itself has errors. :-(
    parser = require('lint.parser').from_pattern(pattern, groups, severity_map, {
      ['source'] = 'perlcritic',
    }),
  }
end
