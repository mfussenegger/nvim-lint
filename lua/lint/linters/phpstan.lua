local bin = 'phpstan'

return {
  cmd = function ()
    local local_bin = vim.fn.fnamemodify('vendor/bin/' .. bin, ':p')
    return vim.loop.fs_stat(local_bin) and local_bin or bin
  end,
  args = {
    'analyze',
    '--error-format=json',
    '--no-progress',
  },
  ignore_exitcode = true,
  parser = function(output, bufnr)
    if vim.trim(output) == '' or output == nil then
      return {}
    end

    local file = vim.json.decode(output).files[vim.api.nvim_buf_get_name(bufnr)]

    if file == nil then
      return {}
    end

    local diagnostics = {}

    for _, message in ipairs(file.messages or {}) do
      local lnum = type(message.line) == "number" and (message.line - 1) or 0
      local linecont = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ""
      local col = linecont:match("()%S") or 0
      local end_col = linecont:match(".*%S()") or 0

      table.insert(diagnostics, {
        lnum = lnum,
        col = col - 1,
        end_col = end_col - 1,
        message = message.message,
        source = bin,
        code = message.identifier,
      })
    end

    return diagnostics
  end,
}
