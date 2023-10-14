local severities = {
  nil,
  vim.diagnostic.severity.ERROR,
  vim.diagnostic.severity.WARN,
}

return require('lint.util').inject_cmd_exe({
  cmd = function()
    local local_eslint = vim.fn.fnamemodify('./node_modules/.bin/eslint', ':p')
    local stat = vim.loop.fs_stat(local_eslint)
    if stat then
      return local_eslint
    end
    return 'eslint'
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
    local success, decodedData = pcall(vim.json.decode, output)
    local diagnostics = {}

    if success and decodedData ~= nil then
      for _, diagnostic in ipairs(decodedData.messages or {}) do
        table.insert(diagnostics, {
          source = "eslint",
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
