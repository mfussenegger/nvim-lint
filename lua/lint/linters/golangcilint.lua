local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  refactor = vim.diagnostic.severity.INFO,
  convention = vim.diagnostic.severity.HINT,
}

return {
  cmd = 'golangci-lint',
  append_fname = false,
  args = {
    'run',
    '--out-format',
    'json',
    function()
      return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
    end
  },
  stream = 'stdout',
  ignore_exitcode = true,
  parser = function(output, bufnr)
    if output == '' then
      return {}
    end
    local decoded = vim.json.decode(output)
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
          lnum = item.Pos.Line > 0 and item.Pos.Line - 1 or 0,
          col = item.Pos.Column > 0 and item.Pos.Column - 1 or 0,
          end_lnum = item.Pos.Line > 0 and item.Pos.Line - 1 or 0,
          end_col = item.Pos.Column > 0 and item.Pos.Column - 1 or 0,
          severity = sv,
          source = item.FromLinter,
          message = item.Text,
        })
      end
    end
    return diagnostics
  end
}
