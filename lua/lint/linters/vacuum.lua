---@type { [string]: vim.diagnostic.Severity }
local severities = {
  error = vim.diagnostic.severity.ERROR,
  warn = vim.diagnostic.severity.WARN,
  info = vim.diagnostic.severity.INFO,
  hint = vim.diagnostic.severity.HINT,
}

---@type lint.Linter
return {
  name = 'vacuum',
  cmd = 'vacuum',
  args = { 'report', '--no-pretty', '--no-style', '--stdin', '--stdout' },
  stdin = true,
  parser = function(output)
    if vim.trim(output) == '' then
      return {}
    end

    local results = vim.fn.json_decode(output)['resultSet'].results

    local diagnostics = {}
    for _, result in pairs(results or {}) do
      local range_start = result.range['start']
      local range_end = result.range['end']

      table.insert(diagnostics, {
        lnum = range_start.line - 1,
        end_lnum = range_end.line - 1,
        col = range_start.character - 1,
        end_col = range_end.character - 1,
        severity = severities[result['ruleSeverity']],
        message = result.message,
        source = 'vacuum',
        code = result['ruleId']
      })
    end

    return diagnostics
  end
}
