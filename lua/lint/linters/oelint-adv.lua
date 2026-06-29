-- path/to/file:line:severity:code:message
local pattern = '([^:]+):(%d+):(%a+):([^:]+):(.+)'
local groups = { 'file', 'lnum', 'severity', 'code', 'message' }
local severity_map = {
  ['error'] = vim.diagnostic.severity.ERROR,
  ['warning'] = vim.diagnostic.severity.WARN,
  ['info'] = vim.diagnostic.severity.INFO,
}

local function find_config()
  local conf = vim.fs.find('.oelint.cfg', {
    upward = true,
    stop = vim.fs.dirname(vim.loop.os_homedir()),
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
  })
  return conf[1] or ''
end

return function()
  return {
    cmd = 'oelint-adv',
    stdin = false,
    args = {
      '--quiet',
      '--messageformat={path}:{line}:{severity}:{id}:{msg}',
    },
    env = {
      ["NO_COLOR"] = "1",
      ["HOME"] = os.getenv("HOME"),
      ["OELINT_CONFIG"] = find_config(),
    },
    ignore_exitcode = true,
    stream = 'stderr',
    parser = require('lint.parser').from_pattern(
      pattern, groups, severity_map,
      { ['source'] = 'oelint-adv' }
    ),
  }
end
