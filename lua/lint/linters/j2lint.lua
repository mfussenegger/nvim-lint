local severity_map = {
  HIGH = vim.diagnostic.severity.ERROR,
  MEDIUM = vim.diagnostic.severity.WARN,
  LOW = vim.diagnostic.severity.INFO,
}

local function add_issues(diagnostics, issues, min_severity)
  for _, issue in ipairs(issues or {}) do
    local severity = severity_map[issue.severity] or vim.diagnostic.severity.ERROR
    table.insert(diagnostics, {
      lnum = issue.line_number - 1,
      col = 0,
      message = issue.message,
      code = issue.id,
      -- only matters if -w is added via args: warned rules keep their own severity, don't show them as errors
      severity = math.max(severity, min_severity),
      source = "j2lint",
    })
  end
end

return {
  cmd = "j2lint",
  stdin = true,
  args = { "--json", "--stdin" },
  stream = "stdout",
  ignore_exitcode = true,
  parser = function(output)
    if vim.trim(output) == "" then
      return {}
    end
    local data = vim.json.decode(output)
    local diagnostics = {}
    add_issues(diagnostics, data.ERRORS, vim.diagnostic.severity.ERROR)
    add_issues(diagnostics, data.WARNINGS, vim.diagnostic.severity.WARN)
    return diagnostics
  end,
}
