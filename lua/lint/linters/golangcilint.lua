local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
  refactor = vim.lsp.protocol.DiagnosticSeverity.Information,
  convention = vim.lsp.protocol.DiagnosticSeverity.Hint,
}

return {
  cmd = 'golangci-lint',
  stdin = true,
  args = {
    'run',
    '--out-format',
    'json',
    function()
      local bufnr = vim.api.nvim_get_current_buf()
      return vim.api.nvim_buf_get_name(bufnr)
    end
  },
  stream = 'stdout',
  ignore_exitcode = true,
  parser = function(output, bufnr)
    if output == '' then
      return {}
    end
    local decoded = vim.fn.json_decode(output)
    if decoded["Issues"] == nil or type(decoded["Issues"]) == 'userdata' then
      return {}
    end

    local diagnostics = {}
    for _, item in ipairs(decoded["Issues"]) do
      local sv = vim.lsp.protocol.DiagnosticSeverity.Warning
      if severities[item.Severity] ~= nil then
        sv = severities[item.Severity]
      end
      table.insert(diagnostics, {
        range = {
          ['start'] = {
            line = item.Pos.Line - 1,
            character = item.Pos.Column - 1,
          },
          ['end'] = {
            line = item.Pos.Line - 1,
            character = item.Pos.Column - 1,
          },
        },
        severity = sv,
        message = item.Text,
      })
    end
    return diagnostics
  end
}
