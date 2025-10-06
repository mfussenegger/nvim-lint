return {
  cmd = "dclint",
  stdin = false, -- dclint does not take input via stdin
  append_fname = true, -- Automatically append the filename to args
  args = {}, -- No additional arguments required
  stream = "stdout", -- dclint outputs to stdout
  ignore_exitcode = true, -- dclint might return non-zero exit codes for warnings/errors
  parser = require("lint.parser").from_pattern(
    [[^%s*(%d+):(%d+)%s+(%w+)%s+(.+)%s+%S+$]],
    { "lnum", "col", "severity", "message" },
    {
      error = vim.diagnostic.severity.ERROR,
      warning = vim.diagnostic.severity.WARN,
    },
    { source = "dclint" }
  ),
}
