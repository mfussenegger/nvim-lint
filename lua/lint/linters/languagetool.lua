return {
  cmd = 'languagetool',
  args = {'--autoDetect', '--json'},
  stream = 'stdout',
  parser = function(output, bufnr)
    local decoded = vim.fn.json_decode(output)
    local diagnostics = {}
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    local content = table.concat(lines, '\n')
    for _, match in pairs(decoded.matches or {}) do
      local byteidx = vim.fn.byteidx(content, match.offset)
      local line = vim.fn.byte2line(byteidx)
      local col = byteidx - vim.fn.line2byte(line)
      local position = {
        line = line - 1,
        character = col + 1,
      }
      table.insert(diagnostics, {
        range = {
          ['start'] = position,
          ['end'] = position,
        },
        message = match.message,
      })
    end
    return diagnostics
  end,
}
