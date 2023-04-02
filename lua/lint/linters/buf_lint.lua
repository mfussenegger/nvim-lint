return {
  cmd = 'buf',
  args = { 'lint', '--error-format', 'json' },
  stdin = false,
  ignore_exitcode = true,
  parser = function(output)
    if output == '' then
      return {}
    end
    local lines = vim.split(output, '\n')
    local diagnostics = {}
    for _, line in ipairs(lines) do
      if line == '' then
        break
      end
      local item = vim.json.decode(line)
      if item then
        table.insert(diagnostics, {
          lnum = (item.start_line or 1) - 1,
          col = (item.start_column or 1) - 1,
          end_lnum = (item.end_line or 1) - 1,
          end_col = (item.end_column or 1) - 1,
          severity = vim.diagnostic.severity.WARN,
          source = item.type,
          message = item.message,
        })
      end
    end
    return diagnostics
  end,
}
