local severity_map = {
  ["E"] = vim.diagnostic.severity.ERROR,
  ["C"] = vim.diagnostic.severity.WARN,
  ["OB"] = vim.diagnostic.severity.INFO,
  ["MOD"] = vim.diagnostic.severity.INFO,
  ["S"] = vim.diagnostic.severity.INFO,
  ["PORT"] = vim.diagnostic.severity.INFO,
  ["FORT"] = vim.diagnostic.severity.INFO,
}

return {
  cmd = "fortitude",
  stdin = false,
  append_fname = true,
  args = { "check", "--output-format", "json" },
  stream = nil,
  ignore_exitcode = true,
  env = nil,
  parser = function(output, bufnr)
    if output == nil or output:match("^%s*$") ~= nil then
      return {}
    end

    local output_decoded = vim.json.decode(output)

    local diagnostics = {}

    for _, item in ipairs(output_decoded) do
      local location = item.location
      local end_location = item.end_location

      -- Fortitude renamed `row` to `line` (PlasmaFAIR/fortitude@0eda11975096517b16bf30bf683011f83a24e55e)
      local line = location.line or location.row
      local end_line = end_location.line or end_location.row

      table.insert(diagnostics, {
        bufnr = bufnr,
        lnum = line - 1,
        end_lnum = end_line - 1,
        col = location.column - 1,
        end_col = end_location.column - 1,
        severity = severity_map[item.code:match("^(%a+)(%d+)")] or vim.diagnostic.severity.WARN,
        message = item.message,
        source = "fortitude",
        code = item.code,
      })
    end

    return diagnostics
  end,
}
