local severities = {
  HIGH = vim.diagnostic.severity.ERROR,
  LOW = vim.diagnostic.severity.WARN,
  INFO = vim.diagnostic.severity.INFO,
}

return {
  cmd = "salt-lint",
  stdin = true,
  args = { "--json" },
  stream = "stdout",
  ignore_exitcode = true,
  parser = function(output)
    local decoded = vim.json.decode(output)
    local diagnostics = {}
    for _, item in ipairs(decoded or {}) do
      table.insert(diagnostics, {
        lnum = item.linenumber - 1,
        col = 1,
        severity = severities[item.severity] or vim.diagnostic.severity.WARN,
        message = item.message,
        source = "salt-lint",
        code = item.id,
      })
    end
    return diagnostics
  end,
}
