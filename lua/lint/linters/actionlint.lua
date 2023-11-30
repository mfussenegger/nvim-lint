return {
  cmd = 'actionlint',
  stdin = true,
  args = { '-format', '{{json .}}', '-' },
  ignore_exitcode = true,
  parser = function(output)
    if output == '' then
      return {}
    end
    local decoded = vim.json.decode(output)
    if decoded == nil then
      return {}
    end
    local diagnostics = {}
    for _, item in ipairs(decoded) do
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
    return diagnostics
  end,
}
