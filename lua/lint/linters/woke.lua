local severities = {
  warn = vim.diagnostic.severity.WARN,
  warning = vim.diagnostic.severity.WARN,
  error = vim.diagnostic.severity.ERROR,
  info = vim.diagnostic.severity.INFO,
  hint = vim.diagnostic.severity.HINT,
}

return {
  cmd = "woke",
  args = { "--stdin", "--output=json" },
  stdin = true,
  parser = function(output, _)
    if output == "" or vim.trim(output) == "No findings found." then
      return {}
    end
    local decoded = vim.json.decode(output)
    if decoded == nil then
      return {}
    end
    local diagnostics = {}
    for _, item in ipairs(decoded.Results) do
      local msg = item.Rule.Note
      if not msg or msg == "" then
        msg = item.Reason
      end
      table.insert(diagnostics, {
        lnum = item.StartPosition.Line - 1,
        end_lnum = item.EndPosition.Line - 1,
        col = item.StartPosition.Column,
        end_col = item.EndPosition.Column,
        severity = assert(
          severities[item.Rule.Severity],
          "Missing mapping for severity " .. item.Rule.Severity
        ),
        source = "woke",
        code = item.Rule.Name,
        message = msg,
      })
    end
    return diagnostics
  end,
}
