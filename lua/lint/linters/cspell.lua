local efm = '%f:%l:%c - %m'
return {
  cmd = 'cspell',
  ignore_exitcode = true,
  args = {
    'lint',
    '--no-color',
    '--no-progress',
    '--no-summary',
    function()
      return 'stdin://' .. vim.api.nvim_buf_get_name(0)
    end,
  },
  stdin = true,
  stream = 'stdout',
  parser = function(output, bufnr)
    local lines = vim.split(output, '\n')
    local qflist = vim.fn.getqflist({ efm = efm, lines = lines })
    local result = {}
    for _, item in pairs(qflist.items) do
      if item.valid == 1 then
        local message = item.text:match('^%s*(.-)%s*$')
        local word = message:match('%((.-)%)')
        local lnum = math.max(0, item.lnum - 1)
        local line_text = vim.api.nvim_buf_get_lines(bufnr or 0, lnum, lnum + 1, false)[1]
        local col_char = math.max(0, item.col - 1)
        local col_byte, end_col_byte
        if line_text then
          if vim.fn.has('nvim-0.11') == 1 then
            col_byte = vim.str_byteindex(line_text, 'utf-16', col_char, false)
          else
            col_byte = vim.str_byteindex(line_text, col_char, true)
          end
          end_col_byte = col_byte + vim.fn.strdisplaywidth(word)
        else
          col_byte = col_char
          end_col_byte = col_char + vim.fn.strdisplaywidth(word)
        end
        local diagnostic = {
          lnum = lnum,
          col = col_byte,
          end_lnum = lnum,
          end_col = end_col_byte,
          message = message,
          source = 'cspell',
          severity = vim.diagnostic.severity.INFO,
        }
        table.insert(result, diagnostic)
      end
    end
    return result
  end
}
