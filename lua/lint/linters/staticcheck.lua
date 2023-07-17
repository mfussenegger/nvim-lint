local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  ignored = vim.diagnostic.severity.INFO,
}

return {
  cmd = 'staticcheck',
  stdin = false,
  args = {
    '-f', 'json',
  },
  ignore_exitcode = true,
  parser = function(output, bufnr)
    local result = vim.fn.split(output, "\n")
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local diagnostics = {}
    for _, message in ipairs(result) do
      local decoded = vim.json.decode(message)
      if decoded.location.file == bufname then
        table.insert(diagnostics, {
          lnum = decoded.location.line - 1,
          col = decoded.location.column - 1,
          end_lnum = decoded["end"]["line"] - 1,
          end_col = decoded["end"]["column"] - 1,
          code = decoded.code,
          user_data = {
            lsp = {
              code = decoded.code,
            }
          },
          severity = assert(severities[decoded.severity], 'missing mapping for severity ' .. decoded.severity),
          message = decoded.message,
        })
      end
    end
    return diagnostics
  end,
}
