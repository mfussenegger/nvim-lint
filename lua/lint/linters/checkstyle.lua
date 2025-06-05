local M

local function config()
  if M.config_file == nil then
    error(
      "Missing checkstyle config. e.g.: `require('lint.linters.checkstyle').config_file = '/path/to/checkstyle_config.xml'`"
    )
  end
  return M.config_file
end

M = {
  cmd = "checkstyle",
  args = {"-f", "sarif", "-c", config},
  ignore_exitcode = true,
  parser = require('lint.parser').for_sarif({}),
  -- use the bundled Google style by default
  config_file = '/google_checks.xml'
}

return M
