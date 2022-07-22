local function get_cur_file_name(bufnr)
  bufnr = bufnr or 0
  local str, _ = string.gsub(vim.api.nvim_buf_get_name(bufnr), '\\', '/')
  return str
end

local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  information = vim.diagnostic.severity.INFO,
  hint = vim.diagnostic.severity.HINT,
}

return {
  cmd = 'lint-openapi.cmd',
  stdin = true,
  args = {
    '--json',
    get_cur_file_name(0)
  },
  ignore_exitcode = true,
  append_fname = false,
  parser = function(output, _)
    if vim.trim(output) == '' then
      return {}
    end
    local decoded = vim.fn.json_decode(output)
    local diagnostics = {}
    local items_err = decoded['errors']
    local items_warn = decoded['warnings']
    for _, item in pairs(items_err or {}) do
      table.insert(diagnostics, {
        lnum = item.line - 1,
        end_lnum = item.line - 1,
        col = 1,
        end_col = 1,
        message = item.message .. ' | rule: ' .. item.rule,
        source = 'lint-openapi',
        severity = severities['error'],
      })
    end
    for _, item in pairs(items_warn or {}) do
      table.insert(diagnostics, {
        lnum = item.line - 1,
        end_lnum = item.line - 1,
        col = 1,
        end_col = 1,
        message = item.message .. ' | rule: ' .. item.rule,
        source = 'lint-openapi',
        severity = severities['warning'],
      })
    end
    return diagnostics
  end
}
