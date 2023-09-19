
local function get_cur_file_extension(bufnr)
  bufnr = bufnr or 0
  return "." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':e')
end

local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  information = vim.diagnostic.severity.INFO,
  hint = vim.diagnostic.severity.HINT,
  suggestion = vim.diagnostic.severity.HINT,
}

return {
  cmd = 'vale',
  stdin = true,
  args = {
    '--no-exit',
    '--output', 'JSON',
    '--ext', get_cur_file_extension
  },
  parser = function(output, bufnr)
    if vim.trim(output) == '' then
      return {}
    end
    local decoded = vim.json.decode(output)
    local diagnostics = {}
    local items = decoded['stdin' .. get_cur_file_extension(bufnr)]
    for _, item in pairs(items or {}) do
      local curline = unpack(vim.api.nvim_buf_get_lines(bufnr, item.Line-1, item.Line, false))
      -- Vale can report diagnostics not specific to a line/word but about the overall document in the first line.
      -- An example are the readability scores.
      -- The first line could be empty in which case the conversion here would fail
      local ok, column = pcall(vim.str_byteindex, curline, item.Span[1])
      if not ok then
        column = 1
      end
      local end_column
      ok, end_column = pcall(vim.str_byteindex, curline, item.Span[2])
      if not ok then
        end_column = #curline
      end
      table.insert(diagnostics, {
        lnum = item.Line - 1,
        end_lnum = item.Line - 1,
        col = column - 1,
        end_col = end_column,
        message = item.Message,
        source = 'vale',
        code = item.Check,
        severity = assert(severities[item.Severity], 'missing mapping for severity ' .. item.Severity),
      })
    end
    return diagnostics
  end
}
