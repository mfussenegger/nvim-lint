---@class nvim-lint.pyrefly.diagnostics
---@field errors nvim-lint.pyrefly.error[]

---@class nvim-lint.pyrefly.error
---@field line number
---@field column number
---@field stop_line number
---@field stop_column number
---@field path string
---@field code number
---@field name string
---@field description string
---@field concise_description string
---@field severity string

return {
  cmd = "pyrefly",
  stdin = true,
  stream = "stdout",
  ignore_exitcode = true,
  args = {
    "check",
    "--output-format",
    "json",
  },
  parser = function(output)
    ---@type nvim-lint.pyrefly.diagnostics
    local json_data = vim.json.decode(output)

    local severities = {
      ERROR = vim.diagnostic.severity.ERROR,
      WARN = vim.diagnostic.severity.WARN,
      INFO = vim.diagnostic.severity.HINT,
    }

    local diagnostics = {}

    for _, error in ipairs(json_data.errors) do
      table.insert(diagnostics, {
        source = "pyrefly",
        lnum = error.line - 1,
        col = error.column - 1,
        end_lnum = error.stop_line - 1,
        end_col = error.stop_column,
        severity = severities[error.severity],
        message = error.description,
        code = error.name,
      })
    end
    return diagnostics
  end,
}
