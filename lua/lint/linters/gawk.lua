local patterns = {
  ":(%d+):.-\n*%^%s*(%S.*)",
  ":(%d+):%s*(%a+):%s*(.+)",
}

local severities = {
  warning = vim.diagnostic.severity.WARN,
  error = vim.diagnostic.severity.ERROR,
}

return {
  cmd = "gawk",
  args = { "-f-", "-L" },
  stdin = true,
  stream = "stderr",
  ignore_exitcode = true,
  parser = function(output, bufnr)
    local diagnostics = {}
    for line in output:gmatch("[^\r\n]+") do
      for _, pat in ipairs(patterns) do
        local lnum, sev, msg = line:match(pat)
        if lnum then
          table.insert(diagnostics, {
            bufnr = bufnr,
            source = "gawk",
            lnum = tonumber(lnum) - 1,
            col = 0,
            severity = severities[sev:lower()] or severities.error,
            message = msg or sev,
          })
          break
        end
      end
    end
    return diagnostics
  end,
}
