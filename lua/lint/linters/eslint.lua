local severities = {
  vim.diagnostic.severity.WARN,
  vim.diagnostic.severity.ERROR,
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
  parser = function(output, buffer)
    local success, data = pcall(vim.json.decode, output)
    local diagnostics = {}

    for _, item in ipairs(data) do
      local current_file = vim.api.nvim_buf_get_name(buffer)
      local linted_file = item.filePath

      if current_file == linted_file then
        for _, diagnostic in ipairs(item.messages or {}) do
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
    end

    return diagnostics
  end
})
