return {
  cmd = "fortitude",
  stdin = true,
  append_fname = true,
  args = { "check", "--output-format", "json" },
  stream = nil,
  ignore_exitcode = true,
  env = nil,
  parser = function(output, bufnr, linter_cwd)
    if output == nil or output:match("^%s*$") ~= nil then
      return {}
    end

    local severity_map = {
      ["E"] = vim.diagnostic.severity.ERROR,
      ["C"] = vim.diagnostic.severity.WARN,
      ["OB"] = vim.diagnostic.severity.INFO,
      ["MOD"] = vim.diagnostic.severity.INFO,
      ["S"] = vim.diagnostic.severity.INFO,
      ["PORT"] = vim.diagnostic.severity.INFO,
      ["FORT"] = vim.diagnostic.severity.INFO,
    }

    local output_decoded = vim.json.decode(output)

    local diagnostics = {}

    for _, item in pairs(output_decoded) do
      table.insert(diagnostics, {
        bufnr = bufnr,
        lnum = item.location.row - 1,
        end_lnum = item.end_location.row - 1,
        col = item.location.column - 1,
        end_col = item.end_location.column - 1,
        severity = severity_map[item.code:match("^(%a+)(%d+)")] or vim.diagnostic.severity.WARN,
        message = item.message,
        source = "fortitude",
        code = item.code,
      })
    end

    return diagnostics
  end,
}
