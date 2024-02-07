local severities = {
  vim.diagnostic.severity.HINT,
  vim.diagnostic.severity.INFO,
  vim.diagnostic.severity.WARN,
  vim.diagnostic.severity.ERROR,
}

return function(ruleset)
  return {
    cmd = 'spectral',
    stdin = false,
    append_fname = true,
    args = { "lint", "-r", ruleset, "-f", "json", },
    stream = "stdout",
    ignore_exitcode = true,
    parser = function(output, _)
      local items = {}

      if output == '' then
        return items
      end

      local decoded = vim.json.decode(output) or {}
      local bufpath = vim.fn.expand('%:p')

      -- prevent warning on files that are not OpenAPI specs
      if decoded[1].code == "unrecognized-format" then
        return items
      end

      for _, diag in ipairs(decoded) do
        vim.print(diag.severity)
        if diag.source == bufpath then
          table.insert(items, {
            source = "spectral",
            severity = severities[diag.severity + 1],
            code = diag.code,
            message = diag.message,
            lnum = diag.range.start.line + 1,
            end_lnum = diag.range["end"].line + 1,
            col = diag.range.start.character + 1,
            end_col = diag.range["end"].character + 1,
          })
        end
      end

      return items
    end,
  }
end
