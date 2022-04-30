-- path/to/file:line: severity: 'offending part of source code': message
local pattern = "%s*([^:]+):(%d+): (.+): (.+: .+)"
local groups = { "file", "lnum", "severity", "message" }

return {
  cmd = "glslc",
  stdin = false,
  args = {"-o", "-"}, -- "-" represents output of compilation result to stdout
  ignore_exitcode = true,
  stream = "stderr",
  parser = require("lint.parser").from_pattern(pattern, groups, {
    error = vim.diagnostic.severity.ERROR,
    warning = vim.diagnostic.severity.WARN,
  }, {
      ["source"] = "glslc",
      ["severity"] = vim.diagnostic.severity.WARN,
    }),
}
