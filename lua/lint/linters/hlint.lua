local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  suggestion = vim.diagnostic.severity.HINT,
}

return {
  cmd = "hlint",
  args = { "--json", "--no-exit-code" },
  parser = function(output)
    local diagnostics = {}
    local items = #output > 0 and vim.json.decode(output) or {}
    for _, item in ipairs(items) do
      table.insert(diagnostics, {
        lnum = item.startLine,
        col = item.startColumn,
        end_lnum = item.endLine,
        end_col = item.endColumn,
        severity = severities[item.severity:lower()],
        source = "hlint",
        message = item.hint .. (item.to ~= vim.NIL and (": " .. item.to) or ""),
      })
    end
    return diagnostics
  end,
}
