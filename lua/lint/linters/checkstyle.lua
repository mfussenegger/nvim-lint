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
  args = { "-f", "sarif", "-c", config },
  ignore_exitcode = true,
  -- use the bundled Google style by default
  config_file = "/google_checks.xml",
  diagnostic_skeleton = {},
  ---@type lint.SarifOptions
  sarif_config = { default_end_col = "+1" },
}

M.parser = require("lint.parser").for_sarif(M.diagnostic_skeleton, M.sarif_config)

return M
