local linter_name = "bloc"

-- See https://bloclibrary.dev/lint/
local pattern = "(%w+)%[([%w_]+)%]:%s*(.-)\n%s*%-%->%s*.-:(%d+)"

-- See https://bloclibrary.dev/lint/customizing-rules/#customizing-rule-severity
local severity_map = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  info = vim.diagnostic.severity.INFO,
  hint = vim.diagnostic.severity.HINT,
}

---@type lint.parse
local function parse_bloc_output(output)
  local diagnostics = {}

  for severity_str, code, msg, lnum in output:gmatch(pattern) do
    table.insert(diagnostics, {
      source = linter_name,
      code = code,
      message = msg,
      severity = severity_map[severity_str] or vim.diagnostic.severity.WARN,
      lnum = tonumber(lnum) - 1,
      col = 0,
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
