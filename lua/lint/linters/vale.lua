
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
      local column, end_column = string.find(curline, item.Match)
      table.insert(diagnostics, {
        lnum = item.Line - 1,
        end_lnum = item.Line - 1,
        col = column - 1,
        end_col = end_column,
        message = item.Message,
        source = 'vale',
        severity = assert(severities[item.Severity], 'missing mapping for severity ' .. item.Severity),
      })
    end
    return diagnostics
  end
}
