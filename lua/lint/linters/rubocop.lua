local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  fatal = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
  refactor = vim.lsp.protocol.DiagnosticSeverity.Warning,
  convention = vim.lsp.protocol.DiagnosticSeverity.Warning,
  info = vim.lsp.protocol.DiagnosticSeverity.Warning,
}

local function use_bundler()
  local dir = vim.fn.expand('%:p:h')

  if vim.fn.findfile('Gemfile', dir .. ';') == '' then
    return false
  else
    return true
  end
end

return {
  cmd = function(bufnr)
    if use_bundler() then
      return { 'bundle', 'exec', 'rubocop' }
    else
      return 'rubocop'
    end
  end,
  stdin = false,
  args = {
    '--force-exclusion',
    '--format', 'json',
  },
  ignore_exitcode = true,
  parser = function(output, bufnr)
    local items = {}

    -- If there is some sort of error, the output stream is empty. Parsing that
    -- would result in an error when decoding the JSON.
    if output == '' then
      return items
    end

    local decoded = vim.fn.json_decode(output) or {}

    for _, file in ipairs(decoded.files) do
      for _, diag in ipairs(file.offenses) do
        table.insert(items, {
          source = 'rubocop',
          range = {
            ['start'] = {
              line = diag.location.start_line - 1,
              character = diag.location.start_column - 1
            },
            ['end'] = {
              line = diag.location.last_line - 1,
              character = diag.location.last_column
            },
          },
          message = diag.message,
          severity = assert(
            severities[diag.severity],
            'missing mapping for severity ' .. diag.severity
          ),
        })
      end
    end

    return items
  end
}
