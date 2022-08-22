local sqlfluff_pattern = 'L:([^|]+) | P:([^|]+) | ([^|]+) | (.*)'

return {
  cmd = "sqlfluff",
  args = {
    "lint", "--format=json",
    -- note: users will have to replace the --dialect argument accordingly
    "--dialect=postgres", "-",
  },
  ignore_exitcode = true,
  stdin = true,
  parser = function(output, _)
    local per_filepath = #output > 0 and vim.json.decode(output) or {}
    local diagnostics = {}
    for _, i_filepath in ipairs(per_filepath) do
      if i_filepath.filepath == "stdin" then -- only process stdin
        for _, violation in ipairs(i_filepath.violations) do
          table.insert(diagnostics, {
            source = 'sqlfluff',
            lnum = violation.line_no - 1,
            col = violation.line_pos - 1,
            severity = vim.diagnostic.severity.ERROR,
            message = violation.description,
            user_data = {lsp = {code = violation.code}},
          })
        end
      end
    end
    return diagnostics
  end,
}
