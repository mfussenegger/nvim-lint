return {
  cmd = "protolint",
  stdin = false,
  append_fname = true,
  args = { "lint", "--reporter=json" },
  stream = "stderr",
  ignore_exitcode = true,
  env = nil,
  parser = function(output)
    if output == "" then
      return {}
    end
    local json_output = vim.json.decode(output)
    local diagnostics = {}
    if json_output.lints == nil or json_output.lints == vim.NIL then
      return diagnostics
    end
    for _, item in ipairs(json_output.lints) do
      table.insert(diagnostics, {
        lnum = item.line - 1,
        col = item.column - 1,
        message = item.message,
        file = item.filename,
        code = item.rule,
        severity = vim.diagnostic.severity.WARN,
      })
    end
    return diagnostics
  end,
}
