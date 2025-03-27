local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  refactor = vim.diagnostic.severity.INFO,
  convention = vim.diagnostic.severity.HINT,
}

return {
  cmd = 'golangci-lint',
  append_fname = false,
  args = (function()
    if string.find(vim.fn.system { 'golangci-lint', 'version' }, 'version v2') then
      return {
        'run',
        '--output.json.path=stdout',
        '--issues-exit-code=0',
        '--show-stats=false',
        function()
          return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
        end
      }
    else
      return {
        'run',
        '--out-format',
        'json',
        '--issues-exit-code=0',
        '--show-stats=false',
        '--print-issued-lines=false',
        '--print-linter-name=false',
        function()
          return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
        end
      }
    end
  end)(),
  stream = 'stdout',
  parser = function(output, bufnr, cwd)
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
      local curfile_abs = vim.fn.fnamemodify(curfile, ":p")
      local curfile_norm = vim.fs.normalize(curfile_abs)

      local lintedfile = cwd .. "/" .. item.Pos.Filename
      local lintedfile_abs = vim.fn.fnamemodify(lintedfile, ":p")
      local lintedfile_norm = vim.fs.normalize(lintedfile_abs)

      if curfile_norm == lintedfile_norm then
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
