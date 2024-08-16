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
    local pattern = "hledger: Error: %-:(%d+)(%-?(%d*)):(.*)"
    local lnum, _, end_lnum, msg = output:match(pattern)
    lnum = tonumber(lnum)
    end_lnum = tonumber(end_lnum)
    if (lnum or 0) > 0 then
      table.insert(result, {
        message = msg,
        col = 0,
        lnum = lnum - 1,
        end_lnum = end_lnum and (end_lnum - 1) or nil,
        severity = vim.diagnostic.severity.ERROR,
        source = "hledger"
      })
    end
    return result
  end
}
