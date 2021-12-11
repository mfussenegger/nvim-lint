local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  refactor = vim.diagnostic.severity.INFO,
  convention = vim.diagnostic.severity.HINT,
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
      if not item.path or vim.fn.fnamemodify(item.path, ":~:.") == buffer_path then
        local column = 0
        if item.column > 0 then
          column = item.column - 1
        end
        table.insert(diagnostics, {
          lnum = item.line - 1,
          col = column,
          end_lnum = item.line - 1,
          end_col = column,
          severity = assert(severities[item.type], 'missing mapping for severity ' .. item.type),
          message = item.message,
        })
      end
    end
    return diagnostics
  end,
}
