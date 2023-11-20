return {
  cmd = function ()
    local local_tlint = vim.fn.fnamemodify('vendor/bin/tlint', ':p')
    return vim.loop.fs_stat(local_tlint) and local_tlint or 'tlint'
  end,
  stdin = false,
  args = { 'lint', '--json' },
  parser = function(output)
    if output == nil then
      return {}
    end

    local diagnostics = {}

    for _, message in ipairs(vim.json.decode(output).errors or {}) do
      table.insert(diagnostics, {
        lnum = message.line - 1,
        col = 0,
        message = message.message,
        source = 'tlint',
      })
    end

    return diagnostics
  end,
}
