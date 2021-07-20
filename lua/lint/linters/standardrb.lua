local sev = vim.lsp.protocol.DiagnosticSeverity

return {
  cmd = "standardrb",
  args = {"--force-exclusion", "--stdin", "%:p", "--format", "json"},
  stdin = true,
  parser = function(output)
    local diagnostics = {}
    local decoded = vim.fn.json_decode(output)
    local offences = decoded.files[1].offenses

    for _, off in pairs(offences or {}) do
      table.insert(diagnostics, {
        range = {
          ['start'] = {
            line = off.location.start_line - 1,
            character = off.location.start_column - 1
          },
          ['end'] = {
            line = off.location.last_line - 1,
            character = off.location.last_column
          },
        },
        severity = (off.severity == "error" and sev.Error or sev.Warning ),
        message = off.message,
        code = off.cop_name,
      })
    end

   return diagnostics
 end,
}
