local severity_map = {
  ["Error"] = vim.diagnostic.severity.ERROR,
  ["Warning"] = vim.diagnostic.severity.WARN,
  ["Convention"] = vim.diagnostic.severity.HINT,
}

return {
  cmd = "bin/ameba",
  stdin = false,
  append_fname = true,
  args = {
    "--format",
    "json",
  },
  ignore_exitcode = true,
  parser = function(output)
    local diagnostics = {}
    local decoded = vim.json.decode(output)

    if not decoded.sources[1] then
      return diagnostics
    end

    local issues = decoded.sources[1].issues
    for _, issue in pairs(issues) do
      table.insert(diagnostics, {
        source = "ameba",
        code = issue.rule_name,
        lnum = issue.location.line - 1,
        col = issue.location.column - 1,
        end_col = issue.end_location.column,
        end_lnum = issue.end_location.line - 1,
        message = issue.message,
        severity = severity_map[issue.severity],
      })
    end

    return diagnostics
  end,
}
