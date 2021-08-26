
local function get_cur_file_extension(bufnr)
  bufnr = bufnr or 0
  return "." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':e')
end

local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
  information = vim.lsp.protocol.DiagnosticSeverity.Information,
  hint = vim.lsp.protocol.DiagnosticSeverity.Hint,
  suggestion = vim.lsp.protocol.DiagnosticSeverity.Hint,
}

return {
  cmd = 'vale',
  stdin = true,
  args = {
    '--no-exit',
    '--output', 'JSON',
    '--ext', get_cur_file_extension
  },
  parser = function(output, bufnr)
    if vim.trim(output) == '' then
      return {}
    end
    local decoded = vim.fn.json_decode(output)
    local diagnostics = {}
    local items = decoded['stdin' .. get_cur_file_extension(bufnr)]
    for _, item in pairs(items or {}) do
      table.insert(diagnostics, {
        range = {
          ['start'] = {
            line = item.Line - 1,
            character = item.Span[1] - 1,
          },
          ['end'] = {
            line = item.Line - 1,
            character = item.Span[2] - 1,
          },
        },
        message = item.Message,
        severity = assert(severities[item.Severity], 'missing mapping for severity ' .. item.Severity),
      })
    end
    return diagnostics
  end
}
