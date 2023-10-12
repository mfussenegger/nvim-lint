local severities = {
  nil,
  vim.diagnostic.severity.ERROR,
  vim.diagnostic.severity.WARN,
}

return require('lint.util').inject_cmd_exe({
  cmd = function()
    local local_eslintd = vim.fn.fnamemodify('./node_modules/.bin/eslint_d', ':p')
    local stat = vim.loop.fs_stat(local_eslintd)
    if stat then
      return local_eslintd
    end
    return 'eslint_d'
  end,
  args = {
    '--format',
    'json',
    '--stdin',
    '--stdin-filename',
    function() return vim.api.nvim_buf_get_name(0) end,
  },
  stdin = true,
  stream = 'stdout',
  ignore_exitcode = true,
  parser = function(output)
    local json = vim.json.decode(output) or {}
    local diagnostics = {}

    for _, file in ipairs(json or {}) do
      for _, diagnostic in ipairs(file.messages or {}) do
        table.insert(diagnostics, {
          source = "eslint_d",
          lnum = diagnostic.line - 1,
          col = diagnostic.column - 1,
          end_lnum = diagnostic.endLine - 1,
          end_col = diagnostic.endColumn - 1,
          severity = severities[diagnostic.severity],
          message = diagnostic.message,
          code = diagnostic.ruleId
        })
      end
    end

    return diagnostics
  end
})
