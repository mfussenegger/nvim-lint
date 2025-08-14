local M
local function rulesets()
  if M.rulesets == nil then
    error(
      "Missing pmd ruleset. e.g.: `require('lint.linters.pmd').rulesets = '/rulesets/java/quickstart.xml,/path/to/custom/ruleset.xml'`"
    )
  end
  return M.rulesets
end

M = {
  cmd = "pmd",
  stdin = false,
  args = {
    "check",
    "--format", "sarif",
    "--rulesets", rulesets,
    "--dir",
  },
  ignore_exitcode = true,
  -- Use the suggested one by default.
  rulesets = "rulesets/java/quickstart.xml",
  parser = require("lint.parser").for_sarif()
}

return M
