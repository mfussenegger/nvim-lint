local severities = {
  critical = vim.diagnostic.severity.ERROR,
  minor = vim.diagnostic.severity.WARN,
}
return {
  cmd = "redocly",
  stdin = false,
  stream = "stdout",
  ignore_exitcode = true,
  args = { "lint", "--format", "codeclimate" },
  parser = function(output, _)
    local decoded = vim.json.decode(output)
    local diagnostics = {}

    for _, msg in ipairs(decoded or {}) do
      table.insert(diagnostics, {
        lnum = msg.location.lines.begin - 1,
        col = 0,
        message = msg.description,
        source = "redocly",
        severity = severities[msg.severity],
      })
    end

    return diagnostics
  end,
}
