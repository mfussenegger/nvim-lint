local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  info = vim.diagnostic.severity.INFO,
  hint = vim.diagnostic.severity.HINT,
}

return {
  cmd = "herb-lint",
  stdin = false,
  args = { "--no-timing", "--no-color", "--json" },
  stream = "stdout",
  ignore_exitcode = true,
  parser = function(output)
    if vim.trim(output) == "" then
      return {}
    end
    local ok, data = pcall(vim.json.decode, output, { luanil = { object = true, array = true } })
    if not ok then
      return {}
    end
    local diagnostics = {}
    for _, offense in ipairs(data.offenses or {}) do
      local s = offense.location.start
      local e = offense.location["end"]
      table.insert(diagnostics, {
        lnum = s.line - 1,
        col = s.column,
        end_lnum = e.line - 1,
        end_col = e.column,
        message = offense.message,
        code = offense.code,
        severity = severities[offense.severity] or vim.diagnostic.severity.WARN,
        source = "herb-lint",
      })
    end
    return diagnostics
  end,
}
