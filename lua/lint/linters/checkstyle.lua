local format = '[%tRROR] %f:%l:%c: %m, [%tRROR] %f:%l: %m, [%tARN] %f:%l:%c: %m, [%tARN] %f:%l: %m'

local M

local function config()
  if M.config_file == nil then
    error "Missing checkstyle config. e.g.: `require('lint.linters.checkstyle').config_file = '/path/to/checkstyle_config.xml'`"
  end
  return M.config_file
end

M = {
  cmd = 'checkstyle',
  args = {'-c', config},
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat(format, {
    source = 'checkstyle',
  }),
  -- use the bundled Google style by default
  config_file = '/google_checks.xml'
}

return M
