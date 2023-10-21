local severity_map = {
  ["low"] = vim.diagnostic.severity.INFO,
  ["medium"] = vim.diagnostic.severity.WARN,
  ["high"] = vim.diagnostic.severity.ERROR,
}

return {
  cmd = "snyk",
  stdin = false,
  append_fname = true,
  args = { "iac", "test", "--json" },
  stream = "stdout",
  ignore_exitcode = true,
  env = nil,
  parser = function(output)
    local diagnostics = {}
    local ok, decoded = pcall(vim.json.decode, output)
    if not ok then
      return diagnostics
    end
    for _, result in ipairs(decoded and decoded.infrastructureAsCodeIssues or {}) do
      local err = {
        source = "snyk",
        message = string.format("%s - %s - %s", result.title, result.issue, result.impact),
        lnum = result.lineNumber - 1,
        end_lnum = result.lineNumber - 1,
        col = 0,
        code = result.id,
        severity = severity_map[result.severity],
      }
      table.insert(diagnostics, err)
    end
    return diagnostics
  end,
}
