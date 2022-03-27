local vim = vim

local severities = {}
severities[2] = vim.diagnostic.severity.ERROR
severities[3] = vim.diagnostic.severity.WARN
--   refactor = vim.diagnostic.severity.INFO,
--   convention = vim.diagnostic.severity.HINT
-- }

local linter = "solhint"

return {
  cmd = linter,
  stdin = false,
  args = {
    "-f",
    "json"
  },
  ignore_exitcode = true,
  parser = function(output, bufnr)
    local diagnostics = {}
    local buffer_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")
    print(buffer_path)

    output = vim.json.decode(output)[1]
    for _, item in ipairs(output.reports or {}) do
      if not item.path or vim.fn.fnamemodify(item.path, ":~:.") == buffer_path then
        table.insert(
          diagnostics,
          {
            source = linter,
            lnum = item.line - 1,
            end_lnum = item.line - 1,
            col = item.column - 1,
            end_col = item.column - 1,
            severity = assert(
              severities[item.severity],
              "missing mapping for severity " .. item.severity
            ),
            message = item.message,
            user_data = {
              lsp = {
                code = item.ruleId
              }
            }
          }
        )
      end
    end
    return diagnostics
  end
}
