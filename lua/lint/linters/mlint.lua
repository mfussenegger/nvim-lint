local pattern = "L (%d+) %(C (%d+)[-]?([%d]*)%): (.-): (.-): (.*)"
local severities = {
  ML2 = vim.lsp.protocol.DiagnosticSeverity.Error,
  ML3 = vim.lsp.protocol.DiagnosticSeverity.Error,
  ML4 = vim.lsp.protocol.DiagnosticSeverity.Error,
  ML1 = vim.lsp.protocol.DiagnosticSeverity.Warning,
  ML0 = vim.lsp.protocol.DiagnosticSeverity.Information,
  ML5 = vim.lsp.protocol.DiagnosticSeverity.Hint,
}

return {
  cmd = "mlint",
  stdin = false,
  stream = "stderr",
  args = { "-cyc", "-id", "-severity" },
  ignore_exitcode = true,
  parser = function(output, _)
    local result = vim.fn.split(output, "\n")
    local diagnostics = {}

    for _, line in ipairs(result) do
      local lineno, start_col, end_col, code, sev, desc = string.match(line, pattern)

      lineno = tonumber(lineno or 1) - 1
      lineno = lineno >= 0 and lineno or 0
      start_col = tonumber(start_col or 1) - 1
      start_col = start_col >= 0 and start_col or 0
      end_col = end_col and tonumber(end_col) or start_col + 1
      table.insert(diagnostics, {
        source = "mlint",
        range = {
          ["start"] = { line = lineno, character = start_col },
          ["end"] = { line = lineno, character = end_col },
        },
        message = desc,
        severity = assert(severities[sev], "missing mapping for severity " .. sev),
        code = code,
      })
    end
    return diagnostics
  end,
}

