local terraform_severity_to_diagnostic_severity = {
  warning = vim.diagnostic.severity.WARN,
  ['error'] = vim.diagnostic.severity.ERROR,
  notice = vim.diagnostic.severity.INFO,
}

return {
  cmd = "tflint",
  args = {"--format=json"},
  append_fname = false,
  stdin = false,
  ignore_exitcode = true,
  parser = function(output, bufnr)
    local decoded = vim.json.decode(output) or {}
    local issues = decoded["issues"] or {}
    local diagnostics = {}
    local buf_path = vim.api.nvim_buf_get_name(bufnr)
    for _, issue in ipairs(issues) do
      -- bug: tflint _may_ eat first «/»
      local issue_path = "/" .. issue.range.filename
      issue_path = string.gsub(issue_path, "^//", "/")

      if issue_path == buf_path then
        table.insert(diagnostics, {
          lnum = assert(tonumber(issue.range.start.line)),
          end_lnum = assert(tonumber(issue.range['end'].line)),
          col = assert(tonumber(issue.range.start.column)),
          end_col = assert(tonumber(issue.range['end'].column)),
          severity = terraform_severity_to_diagnostic_severity[issue.rule
            .severity],
          source = 'tflint',
          message = string.format("%s (%s)\nReference: %s", issue.message,
                                  issue.rule.name, issue.rule.link),
        })
      end
    end
    return diagnostics
  end,
}
