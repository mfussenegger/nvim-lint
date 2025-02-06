-- NOTE: see require("lint.linters.api_linter_buf") for a real-world implementation of api-linter, leveraging the buf CLI.

return {
  cmd = "api-linter",
  stdin = false,
  append_fname = true,
  args = {
    "--output-format=json",
    "--disable-rule=core::0191::java-multiple-files",
    "--disable-rule=core::0191::java-package",
    "--disable-rule=core::0191::java-outer-classname",
  },
  stream = "stdout",
  ignore_exitcode = true,
  env = nil,
  parser = function(output)
    if output == "" then
      return {}
    end
    local json_output = vim.json.decode(output)
    local diagnostics = {}
    if json_output == nil then
      return diagnostics
    end
    for _, item in ipairs(json_output) do
      for _, problem in ipairs(item.problems) do
        table.insert(diagnostics, {
          message = problem.message,
          file = item.file,
          code = problem.rule_id .. " " .. problem.rule_doc_uri,
          severity = vim.diagnostic.severity.WARN,
          lnum = problem.location.start_position.line_number - 1,
          col = problem.location.start_position.column_number - 1,
          end_lnum = problem.location.end_position.line_number - 1,
          end_col = problem.location.end_position.column_number - 1,
        })
      end
    end
    return diagnostics
  end,
}
