local severities = {
  nil,
  vim.diagnostic.severity.ERROR,
  vim.diagnostic.severity.WARN,
}

return require('lint.util').inject_cmd_exe({
  cmd = function()
    local local_eslint_d = vim.fn.fnamemodify('./node_modules/.bin/eslint_d', ':p')
    local stat = vim.loop.fs_stat(local_eslint_d)

    if stat then
      return local_eslint_d
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
    local success, decodedData = pcall(
      vim.json.decode, output,
      { luanil = { object = true, array = true } }
    )
    local messages = decodedData and decodedData[1] and decodedData[1].messages or {}

    local diagnostics = {}
    if success and #messages > 0 then
      for _, diagnostic in ipairs(messages or {}) do
        table.insert(diagnostics, {
          source = "eslint_d",
          lnum = diagnostic.line - 1,
          col = diagnostic.column - 1,
          end_lnum = (diagnostic.endLine or diagnostic.line) - 1,
          end_col = (diagnostic.endColumn or diagnostic.column) - 1,
          severity = severities[diagnostic.severity],
          message = diagnostic.message,
          code = diagnostic.ruleId
        })
      end
    end

    return diagnostics
  end
})
