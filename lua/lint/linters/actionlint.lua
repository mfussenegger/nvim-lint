return {
  cmd = 'actionlint',
  stdin = true,
  args = { '-format', '{{json .}}' },
  ignore_exitcode = true,
  parser = function(output, bufnr)
    if output == '' then
      return {}
    end
    local decoded = vim.json.decode(output)
    if decoded == nil then
      return {}
    end
    local diagnostics = {}
    for _, item in ipairs(decoded) do
      local current_file = vim.api.nvim_buf_get_name(bufnr)
      local linted_file = vim.fn.getcwd() .. '/' .. item.filepath
      if current_file == linted_file then
        table.insert(diagnostics, {
          lnum = item.line - 1,
          end_lnum = item.line - 1,
          col = item.column - 1,
          end_col = item.end_column,
          severity = vim.diagnostic.severity.WARN,
          source = 'actionlint: ' .. item.kind,
          message = item.message,
        })
      end
    end
    return diagnostics
  end,
}
