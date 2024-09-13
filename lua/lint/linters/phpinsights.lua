local bin = 'phpinsights'
local insight_to_severity = {
  Code = vim.diagnostic.severity.ERROR,
  Complexity = vim.diagnostic.severity.WARN,
  Architecture = vim.diagnostic.severity.WARN,
  Style = vim.diagnostic.severity.HINT,
  Security = vim.diagnostic.severity.ERROR,
}

return {
  cmd = function ()
    local local_bin = vim.fn.fnamemodify('vendor/bin/' .. bin, ':p')
    return vim.loop.fs_stat(local_bin) and local_bin or bin
  end,
  stdin = false,
  args = { 'analyse', '--format', 'json' },
  parser = function(output)
    if output == nil then
      return {}
    end

    local diagnostics = {}
    local json = vim.json.decode(output) or {}

    for insight, severity in pairs(insight_to_severity) do
      for _, message in ipairs(json[insight] or {}) do
          table.insert(diagnostics, {
            lnum = (message.line or 1) - 1,
            col = 0,
            message = message.message or message.title,
            severity = severity,
            source = bin,
          })
      end
    end

    return diagnostics
  end,
}
