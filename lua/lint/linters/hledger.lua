return {
  cmd = "hledger",
  stdin = true,
  args = {"check", "-s", "-f", "-"},
  stream = "stderr",
  ignore_exitcode = true,
  parser = function(output)
    --- hledger currently outputs at most one error.
    ---@type vim.Diagnostic[]
    local result = {}
    local pattern = "hledger: Error: %-:(%d+):(.*)"
    local lnum, msg = output:match(pattern)
    if lnum and (tonumber(lnum) or 0) > 0 then
      table.insert(result, {
        message = msg,
        col = 0,
        lnum = tonumber(lnum) - 1,
        severity = vim.diagnostic.severity.ERROR,
        source = "hledger"
      })
    end
    return result
  end
}
