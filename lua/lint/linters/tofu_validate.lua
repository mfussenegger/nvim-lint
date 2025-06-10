local tofu_severity_to_diagnostic_severity = {
  warning = vim.diagnostic.severity.WARN,
  error = vim.diagnostic.severity.ERROR,
  notice = vim.diagnostic.severity.INFO,
}

return function()
  return {
    cmd = "tofu",
    args = { "-chdir=" .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.:h"), "validate", "-json" },
    append_fname = false,
    stdin = false,
    stream = "both",
    ignore_exitcode = true,
    parser = function(output, bufnr)
      local decoded = vim.json.decode(output) or {}
      local result = {}
      local buf_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
      for _, diagnostic in ipairs(decoded.diagnostics or {}) do
        local message = diagnostic.summary
        if diagnostic.detail then
          message = string.format("%s - %s", message, diagnostic.detail)
        end
        local result_diagnostic = {
          message = message,
          lnum = 0,
          col = 0,
          source = "tofu validate",
          severity = tofu_severity_to_diagnostic_severity[new_diagnostic.severity],
          filename = buf_path,
        }
        local range = diagnostic.range
        if range ~= nil and range.filename == buf_path then
          result_diagnostic.col = tonumber(range.start.column) - 1
          result_diagnostic.end_col = tonumber(range["end"].column) - 1
          result_diagnostic.lnum = tonumber(range.start.line) - 1
          result_diagnostic.end_lnum = tonumber(range["end"].line) - 1
          result_diagnostic.filename = tonumber(range.filename)
        end
        table.insert(result, result_diagnostic)
      end
      return result
    end,
  }
end
