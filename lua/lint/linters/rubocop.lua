local severity_map = {
  ['fatal'] = vim.diagnostic.severity.ERROR,
  ['error'] = vim.diagnostic.severity.ERROR,
  ['warning'] = vim.diagnostic.severity.WARN,
  ['convention'] = vim.diagnostic.severity.HINT,
  ['refactor'] = vim.diagnostic.severity.INFO,
  ['info'] = vim.diagnostic.severity.INFO,
}

return {
  cmd = 'rubocop',
  stdin = false,
  args = {'--format', 'json', '--force-exclusion'},
  ignore_exitcode = true,
  parser = function(output)
    local diagnostics = {}
    local decoded = vim.json.decode(output)

    if not decoded.files[1] then
      return diagnostics
    end

    local offences = decoded.files[1].offenses

    for _, off in pairs(offences) do
      table.insert(diagnostics, {
        source = 'rubocop',
        lnum = off.location.start_line - 1,
        col = off.location.start_column - 1,
        end_lnum = off.location.last_line - 1,
        end_col = off.location.last_column,
        severity = severity_map[off.severity],
        message = off.message,
        code = off.cop_name
      })
    end

    return diagnostics
  end,
}
