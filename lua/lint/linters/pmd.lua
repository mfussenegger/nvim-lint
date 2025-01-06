local M

local function rulesets()
  if M.rulesets == nil then
    error(
      "Missing pmd ruleset. e.g.: `require('lint.linters.pmd').rulesets = '/rulesets/java/quickstart.xml,/path/to/custom/ruleset.xml'`"
    )
  end
end

M = {
  cmd = "pmd",
  stdin = false,
  args = {
    "check",
    "--format",
    "sarif",
    "--rulesets",
    rulesets,
    "--dir",
  },
  ignore_exitcode = true,
  -- Use the suggested one by default.
  rulesets = "rulesets/java/quickstart.xml",
  diagnostic_skeleton = {},
  ---@type lint.SarifOptions
  sarif_config = {
    get_severity = function(_, rule)
      if rule == nil then
        return nil
      end

      return math.max(1, rule.properties.priority - 1)
    end,
  },
}

M.parser = require("lint.parser").for_sarif(M.diagnostic_skeleton, M.sarif_config)

return M
