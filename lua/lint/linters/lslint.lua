return {
  cmd = "lslint",
  stdin = true,
  args = { "-w", "-m", "-u", "-z", "-i" },
  stream = "stderr",
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(
    "(%u+):: %(%s*(%d+),%s*(%d+)%): (.+)",
    { "severity", "lnum", "col", "message" },
    {
      ["ERROR"] = vim.diagnostic.severity.ERROR,
      ["WARN"] = vim.diagnostic.severity.WARN,
      ["INFO"] = vim.diagnostic.severity.INFO,
      ["OTHER"] = vim.diagnostic.severity.INFO,
      ["DEBUG"] = vim.diagnostic.severity.INFO,
      ["source"] = "lslint",
    }
  ),
}
