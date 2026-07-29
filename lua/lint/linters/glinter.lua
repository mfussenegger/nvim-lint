local severity_map = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
}

return {
  cmd = "gleam",
  append_fname = false, -- if appended, it could lead to unused_exports false positives
  args = {
    "run",
    "-m",
    "glinter",
    "--",
    "--format",
    "json",
  },
  parser = function(output, bufnr)
    local diagnostics = {}

    if output == nil then
      return diagnostics
    end

    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local offences = vim.json.decode(output).results

    for _, off in pairs(offences) do
      if bufname:sub(- #off.file) == off.file then
        table.insert(diagnostics, {
          source = 'glinter',
          lnum = off.line - 1,
          end_lnum = off.line - 1,
          severity = severity_map[off.severity],
          message = off.message,
          code = off.rule
        })
      end
    end

    return diagnostics
  end,
}
