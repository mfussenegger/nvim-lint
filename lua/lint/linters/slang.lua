local pattern = "^([^:]+):(%d+):(%d+): (%w+): (.+)"

local groups = { "file", "lnum", "col", "severity", "message" }

local severities = {
  ["error"] = vim.diagnostic.severity.ERROR,
  ["warning"] = vim.diagnostic.severity.WARN,
}

return {
  cmd = "slang",
  stdin = false,
  stream = "stderr",
  args = {
    "-Weverything",
  },
  ignore_exitcode = false,
  parser = require("lint.parser").from_pattern(pattern, groups, severities, { ["source"] = "slang" }),
}
