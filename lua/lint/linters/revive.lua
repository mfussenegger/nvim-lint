-- path/to/file:line:col: code message
local pattern = "[^:]+:(%d+):(%d+): (%w+) (.*)"

return {
  cmd = 'revive',
  stdin = false,
  args = {},
  parser = function(output, _)
    local result = vim.fn.split(output, "\n")
    local diagnostics = {}

    for _, message in ipairs(result) do
      local lineno, offset, code, msg = string.match(message, pattern)
      lineno = tonumber(lineno or 1) - 1
      offset = tonumber(offset or 1) - 1
      table.insert(diagnostics, {
        source = 'revive',
        code = code,
        range = {
          ['start'] = {line = lineno, character = offset},
          ['end'] = {line = lineno, character = offset + 1}
        },
        message = code .. ' ' .. msg,
        severity = vim.lsp.protocol.DiagnosticSeverity.Warning,
      })
    end
    return diagnostics
  end
}
