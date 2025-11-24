local severities = {
  Error = vim.diagnostic.severity.ERROR,
  Warning = vim.diagnostic.severity.WARN,
}
return {
  cmd = "squawk",
  args = { "--reporter=json" },
  stream = "stdout",
  stdin = false,
  ignore_exitcode = true,

  parser = function(output, bufnr)
    if output == "" then
      return {}
    end

    local ok, decoded = pcall(vim.json.decode, output)
    if not ok or not decoded then
      return {}
    end
    local diagnostics = {}

    for _, diag in ipairs(decoded) do
      local severity = severities[diag.level]
      local message = diag.message or ""
      if diag.rule_name then
        message = message .. " (" .. diag.rule_name .. ")"
      end
      if diag.help and type(diag.help) == "string" then
        message = message .. "\nHint: " .. diag.help
      end

      table.insert(diagnostics, {
        source = "squawk",
        lnum = diag.line or 0,
        col = diag.column or 0,
        end_lnum = diag.line_end or diag.line or 0,
        end_col = diag.column_end or diag.column or 0,
        message = message,
        severity = severity,
        code = diag.rule_name,
      })
    end

    return diagnostics
  end,
}
