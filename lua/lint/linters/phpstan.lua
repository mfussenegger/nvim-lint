return {
  cmd = 'phpstan',
  args = {
    'analyze',
    '--error-format=json',
    '--no-progress',
  },
  ignore_exitcode = true,
  parser = function(output, bufnr)
    if output == nil then
      return {}
    end

    local file = vim.json.decode(output).files[vim.api.nvim_buf_get_name(bufnr)]

    if file == nil then
      return {}
    end

    local diagnostics = {}

    for _, message in ipairs(file.messages or {}) do
      table.insert(diagnostics, {
        lnum = message.line - 1,
        col = 0,
        message = message.message,
        source = 'phpstan',
      })
    end

    return diagnostics
  end,
}
