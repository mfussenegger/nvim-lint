local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  refactor = vim.diagnostic.severity.INFO,
  convention = vim.diagnostic.severity.HINT,
}

return {
  cmd = 'golangci-lint',
  stdin = true,
  args = {
    'run',
    '--out-format',
    'json',
  },
  stream = 'stdout',
  ignore_exitcode = true,
  parser = function(output, bufnr)
    if output == '' then
      return {}
    end
    local decoded = vim.fn.json_decode(output)
    if decoded["Issues"] == nil or type(decoded["Issues"]) == 'userdata' then
      return {}
    end

    local diagnostics = {}
    for _, item in ipairs(decoded["Issues"]) do
      local curfile = vim.api.nvim_buf_get_name(bufnr)
      local lintedfile = vim.fn.getcwd() .. "/" .. item.Pos.Filename
      if curfile == lintedfile then
        -- only publish if those are the current file diagnostics
        local sv = severities[item.Severity] or severities.warning
        table.insert(diagnostics, {
          lnum = item.Pos.Line - 1,
          col = item.Pos.Column - 1,
          end_lnum = item.Pos.Line - 1,
          end_col = item.Pos.Column - 1,
          severity = sv,
          source = item.FromLinter,
          message = item.Text,
        })
      end
    end
    return diagnostics
  end
}
