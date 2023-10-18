return {
  cmd = function()
    local local_executable = vim.fn.fnamemodify("./bin/dotenv-linter", ":p")
    local stat = vim.loop.fs_stat(local_executable)
    if stat then
      return local_executable
    end
    return "dotenv-linter"
  end,
  stdin = false,
  args = { "--quiet", "--no-color" },
  stream = "stdout",
  ignore_exitcode = true,
  env = nil,

  parser = require("lint.parser").from_pattern(
    [=[%w+:(%d+) (%w+): (.*)]=],
    { "lnum", "code", "message" },
    nil,
    { ["source"] = "dotenv_linter", ["severity"] = vim.diagnostic.severity.INFO }
  ),
}
