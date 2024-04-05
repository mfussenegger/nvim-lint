return {
  cmd = "deadnix",
  stdin = false,
  append_fname = true,
  args = { "--output-format=json" },
  stream = nil,
  ignore_exitcode = false,
  env = nil,
  parser = function(output, _)
    local diagnostics = {}

    if output == "" then
      return diagnostics
    end

    local decoded = vim.json.decode(output) or {}

    for _, diag in ipairs(decoded.results) do
      table.insert(diagnostics, {
        lnum = diag.line - 1,
        end_lnum = diag.line - 1,
        col = diag.column - 1,
        end_col = diag.endColumn,
        message = diag.message,
        severity = vim.diagnostic.severity.WARN,
      })
    end

    return diagnostics
  end,
}
