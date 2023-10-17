local pattern = "%s*(%d+):(%d+)-(%d+):(%d+)%s+(%w+)%s+(.-)%s+%s+(%g+)%s+%g+"
local groups = { "lnum", "col", "end_lnum", "end_col", "severity", "message", "code" }
local severity_map = {
  warning = vim.diagnostic.severity.WARN,
  error = vim.diagnostic.severity.ERROR,
}

return {
  cmd = "alex",
  stdin = true,
  stream = "stderr",
  ignore_exitcode = true,
  args = {
    "--stdin",
    function()
      if vim.bo.ft == "html" then
        return "--html"
      elseif vim.bo.ft ~= "markdown" then
        return "--text"
      end
    end,
  },
  parser = require("lint.parser").from_pattern(
    pattern,
    groups,
    severity_map,
    { severity = vim.diagnostic.severity.WARN, source = "alex" }
  ),
}
