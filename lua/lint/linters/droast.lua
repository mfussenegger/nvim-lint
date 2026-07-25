local severity_map = {
  ERROR = vim.diagnostic.severity.ERROR,
  WARN = vim.diagnostic.severity.WARN,
  INFO = vim.diagnostic.severity.INFO,
}

local function diagnostic_from_finding(finding)
  local line = math.max((finding.line or 1) - 1, 0)
  local column = math.max((finding.column or 1) - 1, 0)
  local diagnostic = {
    lnum = line,
    col = column,
    severity = severity_map[finding.severity] or vim.diagnostic.severity.WARN,
    source = "droast",
    code = finding.rule,
    message = string.format("[%s] %s", finding.rule, finding.message),
  }
  if finding.end_line then
    diagnostic.end_lnum = math.max(finding.end_line - 1, line)
  end
  if finding.end_column then
    diagnostic.end_col = math.max(finding.end_column - 1, column)
  end
  return diagnostic
end

return {
  cmd = "droast",
  stdin = false,
  append_fname = true,
  args = {
    "--format",
    "json",
    "--no-roast",
    "--no-fail",
    "--check-dockerignore=false",
  },
  stream = "both",
  ignore_exitcode = true,
  env = nil,
  parser = function(output)
    if output == "" then
      return {}
    end
    local decoded = vim.json.decode(output)
    local diagnostics = {}
    for _, finding in ipairs(decoded.findings or {}) do
      table.insert(diagnostics, diagnostic_from_finding(finding))
    end
    return diagnostics
  end,
}
