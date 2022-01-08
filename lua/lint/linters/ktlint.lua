return {
  cmd = 'ktlint',
  stdin = true,
  args = { '--android', '--reporter=json', '--stdin' },
  stream = 'stderr',
  ignore_exitcode = true,
  parser = function(output)
    local ktlint_output = vim.fn.json_decode(output)
    if vim.tbl_isempty(ktlint_output) then
      return {}
    end
    local diagnostics = {}
    for _, error in pairs(ktlint_output[1].errors) do
      table.insert(diagnostics, {
        lnum = error.line - 1,
        col = error.column - 1,
        end_lnum = error.line - 1,
        end_col = error.column - 1,
        message = error.message,
        severity = vim.diagnostic.severity.WARN,
        source = 'ktlint',
      })
    end
    return diagnostics
  end
}
