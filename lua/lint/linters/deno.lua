return {
  cmd = "deno",
  stdin = false,
  args = { 'lint', '--json' },
  ignore_exitcode = true,
  parser = function(output)
    local decoded = vim.json.decode(output)
    local diagnostics = {}

    local groups = {
      { name = "diagnostics", severity = vim.diagnostic.severity.WARN },
      { name = "errors",      severity = vim.diagnostic.severity.ERROR }
    }

    for _, group in ipairs(groups) do
      for _, diag in ipairs(decoded[group.name]) do
        -- Parse Error data
        if group.name == "errors" then
          local message, line, col
          _, _, message, line, col = string.find(diag.message, "([%a%p%s]+):(%d+):(%d+)%s*")

          -- build range data
          diag["range"] = {
            start = { line = tonumber(line), col = tonumber(col) },
            ["end"] = { line = tonumber(line), col = tonumber(col) },
          }

          -- override message
          diag["message"] = message
        end

        table.insert(diagnostics, {
          source = "deno",
          lnum = diag.range.start.line - 1,
          col = diag.range.start.col - 1,
          end_lnum = diag.range["end"].line - 1,
          end_col = diag.range["end"].col,
          severity = group.severity,
          message = diag.message,
          code = diag.code
        })
      end
    end

    return diagnostics
  end
}
