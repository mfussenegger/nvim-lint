local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  ignored = vim.diagnostic.severity.INFO,
}

return {
  cmd = 'staticcheck',
  stdin = true,
  args = {
    '-f', 'json',
  },
  ignore_exitcode = true,
  parser = function(output)
    local result = vim.fn.split(output, "\n")
    local diagnostics = {}
    for _, message in ipairs(result) do
      local decoded = vim.fn.json_decode(message)
        table.insert(diagnostics, {
          lnum = decoded.location.line - 1,
          col = decoded.location.column - 1,
          end_lnum = decoded["end"]["line"] - 1,
          end_col = decoded["end"]["column"] - 1,
          user_data = {
            lsp = {
              code = decoded.code,
            }
          },
          severity = assert(severities[decoded.severity], 'missing mapping for severity ' .. decoded.severity),
          message = decoded.message,
        })
    end
    return diagnostics
  end,
}
