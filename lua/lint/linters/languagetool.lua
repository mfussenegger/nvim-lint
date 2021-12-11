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
      table.insert(diagnostics, {
        lnum = line - 1,
        end_lnum = line - 1,
        col = col + 1,
        end_col = col + 1,
        message = match.message,
      })
    end
    return diagnostics
  end,
}
