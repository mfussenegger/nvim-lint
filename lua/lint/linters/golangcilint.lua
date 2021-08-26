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
      local curfile = vim.api.nvim_buf_get_name(bufnr)
      local lintedfile = vim.fn.getcwd() .. "/" .. item.Pos.Filename
      if curfile == lintedfile then
        -- only publish if those are the current file diagnostics
        local sv = severities[item.Severity] or severities.warning
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
  end
  return diagnostics
end
}
