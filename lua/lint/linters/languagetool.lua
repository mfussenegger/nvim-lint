local offset_to_position = require('lint.util').offset_to_position

return {
  cmd = 'languagetool',
  args = {'--autoDetect', '--json'},
  stream = 'stderr',
  parser = function(bufnr, output)
    local decoded = vim.fn.json_decode(output)
    local diagnostics = {}
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    for _, match in pairs(decoded.matches or {}) do
      -- TODO: seems like the offset reported by languagetool isn't what I thought it is?
      -- The reported positions are wrong ?
      local start = offset_to_position(lines, match.offset)
      table.insert(diagnostics, {
        range = {
          ['start'] = start,
          ['end'] = start,
        },
        message = match.message,
      })
    end
    return diagnostics
  end,
}
