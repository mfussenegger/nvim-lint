local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
  refactor = vim.lsp.protocol.DiagnosticSeverity.Information,
  convention = vim.lsp.protocol.DiagnosticSeverity.Hint,
}

return {
  cmd = 'pylint',
  stdin = false,
  args = {
    '-f', 'json'
  },
  ignore_exitcode = true,
  parser = function(output, bufnr)
    local diagnostics = {}
    local buffer_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")

    for _, item in ipairs(vim.fn.json_decode(output) or {}) do
      if not item.file or vim.fn.fnamemodify(item.file, ":~:.") == buffer_path then
        local column = 0
        if item.column > 0 then
          column = item.column - 1
        end
        table.insert(diagnostics, {
          range = {
            ['start'] = {
              line = item.line - 1,
              character = column,
            },
            ['end'] = {
              line = item.line - 1,
              character = column,
            },
          },
          severity = assert(severities[item.type], 'missing mapping for severity ' .. item.type),
          message = item.message,
        })
      end
    end
    return diagnostics
  end,
}
