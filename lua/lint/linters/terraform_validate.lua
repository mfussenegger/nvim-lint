local terraform_severity_to_diagnostic_severity = {
  warning = vim.diagnostic.severity.WARN,
  error = vim.diagnostic.severity.ERROR,
  notice = vim.diagnostic.severity.INFO,
}

return function()
  return {
    cmd = 'terraform',
    args = { 'validate', '-json' },
    append_fname = false,
    stdin = false,
    stream = 'both',
    ignore_exitcode = true,
    cwd = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    parser = function(output, bufnr)
      local decoded = vim.json.decode(output) or {}
      local diagnostics = decoded['diagnostics'] or {}
      local diagnostics_to_show = {}
      local buf_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
      for _, new_diagnostic in ipairs(diagnostics) do
        local message = new_diagnostic.summary
        if new_diagnostic.detail then message = string.format('%s - %s', message, new_diagnostic.detail) end
        local rewritten_diagnostic = {
          message = message,
          lnum = 0,
          col = 0,
          source = 'terraform validate',
          severity = terraform_severity_to_diagnostic_severity[new_diagnostic.severity],
          filename = buf_path,
        }
        if new_diagnostic.range ~= nil and new_diagnostic.range.filename == buf_path then
          rewritten_diagnostic.col = tonumber(new_diagnostic.range.start.column) - 1
          rewritten_diagnostic.end_col = tonumber(new_diagnostic.range['end'].column) - 1
          rewritten_diagnostic.lnum = tonumber(new_diagnostic.range.start.line) - 1
          rewritten_diagnostic.end_lnum = tonumber(new_diagnostic.range['end'].line) - 1
          rewritten_diagnostic.filename = tonumber(new_diagnostic.range.filename)
        end
        table.insert(diagnostics_to_show, rewritten_diagnostic)
      end
      return diagnostics_to_show
    end,
  }
end
