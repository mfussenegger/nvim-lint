local severity_map = {
  info = vim.diagnostic.severity.INFO,
  warning = vim.diagnostic.severity.WARN,
  error = vim.diagnostic.severity.ERROR,
}
local bin = "npm-groovy-lint"

return {
  cmd = bin,
  args = { "-o", "json", "-" },
  stdin = true,
  ignore_exitcode = true,
  parser = function(output, _)
    local diagnostics = {}
    if output == "" then
      return diagnostics
    end

    local ok, decoded = pcall(vim.json.decode, output)
    if not ok or not decoded or not decoded.files then
      return diagnostics
    end

    for _, file_data in pairs(decoded.files) do
      for _, err in ipairs(file_data.errors or {}) do
        local lnum = (err.line or 1) - 1
        local col = 0
        local end_lnum = nil
        local end_col = nil

        if err.range then
          col = err.range.start.character or 0
          end_lnum = (err.range["end"].line or err.line) - 1
          end_col = err.range["end"].character
        end

        table.insert(diagnostics, {
          source = bin,
          lnum = lnum,
          col = col,
          end_lnum = end_lnum,
          end_col = end_col,
          severity = severity_map[err.severity] or vim.diagnostic.severity.WARN,
          message = err.msg,
          code = err.rule,
        })
      end
    end

    return diagnostics
  end,
}
