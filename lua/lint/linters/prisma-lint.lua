local binary_name = "prisma-lint"

return {
  cmd = function()
    local local_binary = vim.fn.fnamemodify('./node_modules/.bin/' .. binary_name, ':p')
    return vim.loop.fs_stat(local_binary) and local_binary or binary_name
  end,
  stdin = false,
  args = {
    "--output-format",
    "json"
  },
  append_fname = true,
  stream = 'both',
  ignore_exitcode = true,
  parser = function(output)
    local decoded = vim.json.decode(output)
    local diagnostics = {}
    if decoded == nil then
      return diagnostics
    end
    for _, violation in pairs(decoded["violations"]) do
      local location = violation.location
      table.insert(diagnostics, {
        source = binary_name,
        lnum = location.startLine - 1,
        end_lnum = location.endLine - 1,
        col = location.startColumn - 1,
        -- endColumn is inclusive, but end_col is exclusive.
        end_col = location.endColumn,
        message = violation.message,
        code = violation.ruleName,
        severity = vim.diagnostic.severity.ERROR,
      })
    end
    return diagnostics
  end,
}
