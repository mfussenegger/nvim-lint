return {
  cmd = 'eugene',
  args = {
    'lint',
    '--format=json',
  },
  stdin = false,
  parser = function(output, _)
    local diagnostics = {}
    if #output > 0 then
      local decoded = vim.json.decode(output)
      for _, stmt in ipairs(decoded.statements) do
        for _, tr in ipairs(stmt.triggered_rules) do
          table.insert(diagnostics, {
            source = 'eugene',
            lnum = stmt.line_number,
            col = 0,
            severity = vim.diagnostic.severity.ERROR,
            message = string.format('%s: %s: %s', tr.id, tr.name, tr.url),
          })
        end
      end
    end
    return diagnostics
  end,
}
