return {
  cmd = "sqlfluff",
  args = {
    "lint", "--format=json",
    -- note: users will have to replace the --dialect argument accordingly
    "--dialect=postgres",
  },
  ignore_exitcode = true,
  stdin = false,
  parser = function(output, _)
    local per_filepath = {}
    if #output > 0 then
      local status, decoded = pcall(vim.json.decode, output)
      if not status then
        per_filepath = {
          {
            filepath = "stdin",
            violations = {
              {
                source = 'sqlfluff',
                line_no = 1,
                line_pos = 1,
                code = 'jsonparsingerror',
                description = output,
              },
            },
          },
        }
      else
        per_filepath = decoded
      end
    end
    local diagnostics = {}
    for _, i_filepath in ipairs(per_filepath) do
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
    return diagnostics
  end,
}
