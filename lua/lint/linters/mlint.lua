local pattern = "L (%d+) %(C (%d+)[-]?([%d]*)%): (.-): (.-): (.*)"
local groups = { "line", "start_col", "end_col", "code", "severity", "message" }
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
  parser = require("lint.parser").from_pattern(pattern, groups, severities, { ["source"] = "mlint" }),
}
