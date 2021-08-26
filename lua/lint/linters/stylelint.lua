local severities = {
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
}

return {
  cmd = "stylelint",
  stdin = true,
  args = {
    "-f",
    "json",
    "--stdin",
    "--stdin-filename",
    "%:p",
  },
  stream = "stdout",
  ignore_exitcode = true,
  parser = function (output)
    local status, decoded = pcall(vim.fn.json_decode, output)
    if status then
      decoded = decoded[1]
    else
      decoded = {
        warnings = {
          {
            line = 1,
            column = 1,
            text = "Stylelint error, run `stylelint " .. vim.fn.expand("%") .. "` for more info.",
            severity = "error",
            rule = "none",
          },
        },
        errored = true,
      }
    end
    local diagnostics = {}
    if decoded.errored then
      for _, message in ipairs(decoded.warnings) do
        table.insert(diagnostics, {
          range = {
            start = {
              line = message.line - 1,
              character = message.column - 1,
            },
            ["end"] = {
              line = message.line - 1,
              character = message.column,
            },
          },
          message = message.text,
          code = message.rule,
          severity = severities[message.severity],
          source = "stylelint",
        })
      end
    end
    return diagnostics
  end
}
