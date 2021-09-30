local format = '[%tRROR] %f:%l: %m, [%tRROR] %f:%l:%c: %m, [%tARN] %f:%l:%c: %m, [%tARN] %f:%l: %m'

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
  config_file = nil
}

return M
