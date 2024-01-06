-- example output:
-- hello_world.ts:48:5: warning: use of undeclared variable: DEV_MODE [E0057]
local pattern = "[^:]+:(%d+):(%d+): (%w+): (.+)"

local groups = { "lnum", "col", "severity", "message" }
local severities = {
  ["error"] = vim.diagnostic.severity.ERROR,
  ["warning"] = vim.diagnostic.severity.WARN,
}

local defaults = { ["source"] = "quick-lint-js" }

return {
  cmd = "quick-lint-js",
  args = {
    "--stdin",
    -- --stdin-path is required to determine the language
    "--stdin-path",
    function()
      return vim.api.nvim_buf_get_name(0)
    end,
  },
  ignore_exitcode = true,
  stream = "stderr",
  parser = require("lint.parser").from_pattern(pattern, groups, severities, defaults),
}
