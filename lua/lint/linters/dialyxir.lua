local severity = {
  warning = vim.diagnostic.severity.WARN,
  error = vim.diagnostic.severity.ERROR,
}

return {
  cmd = "mix",
  stdin = true,
  args = { "dialyzer", "--format", "github", "--quiet-with-result" },
  stream = "stderr",
  ignore_exitcode = true, -- dialyzer only returns 0 if there are no errors
  parser = function (output, bufnr)
    local lines = {}
    for line in output:gmatch("[^\r\n]+") do
      table.insert(lines, line)
    end

    --- @class vim.Diagnostic[]
    local diagnostics = {}
    for _, line in ipairs(lines) do
      local lnum = line:match("line=(%d+)")

      if lnum ~= nil then
        --- @class vim.Diagnostic
        local diagnostic = {
          bufnr = bufnr,
          source = "dialyzer",
          lnum = math.max(tonumber(lnum) - 1, 0),
          col = math.max((tonumber(line:match("col=(%d+)")) or 0) - 1, 0),
          severity = severity[line:match("::(%w+)")],
          message = line:match("::([^:]+)$"),
        }

        table.insert(diagnostics, diagnostic)
      end
    end

    return diagnostics
  end
}
