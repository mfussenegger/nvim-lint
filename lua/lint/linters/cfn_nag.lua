local severity_map = {
  ["WARN"] = vim.diagnostic.severity.WARN,
  ["FAIL"] = vim.diagnostic.severity.ERROR,
}

return {
  cmd = "cfn_nag_scan",
  stdin = false,
  args = { "--output-format", "json", "--input-path" },
  parser = function(output)
    if output == nil then
      return {}
    end

    local diagnostics = {}
    local decoded = vim.json.decode(output)
    local violations = decoded[1].file_results.violations

    for _, violation in pairs(violations) do
      for _, line in pairs(violation.line_numbers) do
        table.insert(diagnostics, {
          lnum = line,
          end_lnum = line,
          col = 1,
          code = violation.id,
          severity = assert(severity_map[violation.type], "missing mapping for severity " .. violation.type),
          message = violation.message,
        })
      end
    end

    return diagnostics
  end,
}
