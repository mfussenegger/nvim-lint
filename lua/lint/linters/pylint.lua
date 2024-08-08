local severities = {
  error = vim.diagnostic.severity.ERROR,
  fatal = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  refactor = vim.diagnostic.severity.INFO,
  info = vim.diagnostic.severity.INFO,
  convention = vim.diagnostic.severity.HINT,
}

return {
  cmd = 'pylint',
  stdin = true,
  args = {
    '-f',
    'json',
    '--from-stdin',
    function()
      return vim.api.nvim_buf_get_name(0)
    end,
  },
  ignore_exitcode = true,
  stream = 'stdout',
  parser = function(output, bufnr)
    if output == "" then return {} end
    local diagnostics = {}
    local buffer_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")

    for _, item in ipairs(vim.json.decode(output) or {}) do
      if not item.path or vim.fn.fnamemodify(item.path, ":~:.") == buffer_path then
        local column = item.column > 0 and item.column or 0
        local end_column = item.endColumn ~= vim.NIL and item.endColumn or column
        table.insert(diagnostics, {
          source = 'pylint',
          lnum = item.line - 1,
          col = column,
          end_lnum = item.line - 1,
          end_col = end_column,
          severity = assert(severities[item.type], 'missing mapping for severity ' .. item.type),
          message = item.message .. " (" .. item.symbol .. ")",
          code = item['message-id'],
          user_data = {
            lsp = {
              code = item['message-id'],
            },
          },
        })
      end
    end
    return diagnostics
  end,
}
