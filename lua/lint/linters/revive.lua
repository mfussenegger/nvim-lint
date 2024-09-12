return {
  cmd = "revive",
  stdin = false,
  args = { "-formatter", "json" },
  parser = function(output, _)
    local severities = {
      error = vim.diagnostic.severity.ERROR,
      warning = vim.diagnostic.severity.WARN,
    }

    local items = {}

    -- revive returns "null" as a string if no errors/warnings were found
    if output == "" or output == "null" then
      return items
    end

    local decoded = vim.json.decode(output)
    -- ensure we got valid json
    if type(decoded) ~= "table" then
      return items
    end

    local bufpath = vim.fn.expand("%:p")

    for _, diag in ipairs(decoded) do
      if diag.Position.Start.Filename == bufpath then
        table.insert(items, {
          source = "revive",
          lnum = diag.Position.Start.Line - 1,
          col = diag.Position.Start.Column - 1,
          end_lnum = diag.Position.End.Line - 1,
          end_col = diag.Position.End.Column - 1,
          message = diag.Failure,
          code = diag.RuleName,
          severity = assert(severities[diag.Severity], "missing mapping for severity " .. diag.Severity),
        })
      end
    end

    return items
  end,
}
