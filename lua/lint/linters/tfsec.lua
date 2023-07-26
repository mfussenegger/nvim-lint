local severity_map = {
  ["MEDIUM"] = vim.diagnostic.severity.WARN,
  ["HIGH"] = vim.diagnostic.severity.ERROR
}

return {
  cmd = 'tfsec',
  stdin = true,
  args = { "-s", "-f", "json" },
  stream = 'stdout',
  parser = function(output, bufnr)
    local diagnostics = {}
    local ok, decoded = pcall(vim.json.decode, output)
    if not ok then
      return diagnostics
    end
    local fpath = vim.api.nvim_buf_get_name(bufnr)
    for _, result in ipairs(decoded and decoded.results or {}) do
      -- Only show results of the current file in the buffer
      if result.location.filename == fpath then
        local err = {
          source = "tfsec",
          message = string.format("%s %s", result.description, result.impact),
          col = result.location.start_line,
          end_col = result.location.end_line,
          lnum = result.location.start_line - 1,
          end_lnum = result.location.end_line - 1,
          code = result.rule_id,
          severity = severity_map[result.severity],
        }
        table.insert(diagnostics, err)
      end
    end
    return diagnostics
  end
}
