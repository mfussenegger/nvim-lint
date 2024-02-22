local severity = {
  ["warn"] = vim.diagnostic.severity.WARN,
  ["error"] = vim.diagnostic.severity.ERROR,
}

return {
  cmd = "io.elementary.vala-lint",
  stdin = false,
  append_fname = true,
  args = {
    "--json-output",
    "--print-end",
  },
  ignore_exitcode = true,
  parser = function(output, bufnr)
    local diagnostics = {}
    local ok, decoded = pcall(vim.json.decode, output)
    if not ok then
      return diagnostics
    end
    local fpath = vim.api.nvim_buf_get_name(bufnr)
    for _, mistake in ipairs(decoded and decoded.mistakes or {}) do
      -- Only show results of the current file in the buffer
      if mistake.filename == fpath then
        local err = {
          source = "vala-lint",
          message = mistake.message,
          col = mistake.column,
          end_col = mistake.endColumn,
          lnum = mistake.line - 1,
          end_lnum = mistake.endLine - 1,
          code = mistake.ruleId,
          severity = severity[mistake.level],
        }
        table.insert(diagnostics, err)
      end
    end
    return diagnostics
  end,
}
