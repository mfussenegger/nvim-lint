local pattern = "^%%(.-)-?(%u*): .-:(%d+):(%d+): (.*)"

local groups = { "severity", "code", "lnum", "col", "message" }

local severities = {
  ["Error"] = vim.diagnostic.severity.ERROR,
  ["Warning"] = vim.diagnostic.severity.WARN,
}

return {
  cmd = "verilator",
  stdin = false,
  stream = "stderr",
  args = {
    "-sv",
    "-Wall",
    "--bbox-sys",
    "--bbox-unsup",
    "--lint-only",
  },
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severities, { ["source"] = "verilator" }),
}
