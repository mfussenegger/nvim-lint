local linter_name = "bloc"

-- See https://bloclibrary.dev/lint/
local pattern = "(%w+)%[([%w_]+)%]:%s*(.-)\n%s*%-%->%s*.-:(%d+)\n%s*|\n%s*|.-\n%s*| (%s*)(%^+)"

-- See https://bloclibrary.dev/lint/customizing-rules/#customizing-rule-severity
local severity_map = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  info = vim.diagnostic.severity.INFO,
}

---@type lint.parse
local function parse_bloc_output(output, bufnr)
  local diagnostics = {}

  for sev_str, code, msg, line_number, spaces, carets in output:gmatch(pattern) do
    local col = #spaces
    local end_col = col + #carets
    local lnum = tonumber(line_number) - 1
    local severity = severity_map[sev_str] or vim.diagnostic.severity.WARN

    table.insert(diagnostics, {
      bufnr = bufnr,
      source = linter_name,
      code = code,
      message = msg,
      severity = severity,
      lnum = lnum,
      col = col,
      end_col = end_col,
    })
  end

  return diagnostics
end

---@type lint.Linter
return {
  name = linter_name,
  cmd = "bloc",
  args = { "lint" },
  stdin = false,
  append_fname = true,
  stream = "stdout",
  ignore_exitcode = true,
  parser = parse_bloc_output,
}
