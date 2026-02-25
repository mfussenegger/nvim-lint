local severity_map = {
  ["LOW"] = vim.diagnostic.severity.INFO,
  ["MEDIUM"] = vim.diagnostic.severity.WARN,
  ["HIGH"] = vim.diagnostic.severity.ERROR,
  ["CRITICAL"] = vim.diagnostic.severity.ERROR,
}

return {
  cmd = "trivy",
  stdin = false,
  append_fname = true,
  args = { "--scanners", "secret", "--format", "json", "fs" },
  stream = "stdout",
  ignore_exitcode = false,
  parser = function(output, bufnr)
    local diagnostics = {}

    local decoded = vim.json.decode(output)
    local fpath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")

    for _, result in ipairs(decoded and decoded.Results or {}) do
      -- trivy can return Results for other files; only report for current buffer
      --
      if result.Target == fpath then
        for _, secret in ipairs(result.Secrets or {}) do
          local title = secret.Title or "<No Title>"
          local id = secret.RuleID or "<No RuleID>"
          local lnum = secret.StartLine and secret.StartLine - 1 or 0
          local end_lnum = secret.EndLine and secret.EndLine - 1 or 0
          table.insert(diagnostics, {
            source = "trivy_secret",
            message = string.format("%s", title),
            col = 0,
            end_col = 0,
            lnum = lnum,
            end_lnum = end_lnum,
            code = id,
            severity = severity_map[secret.Severity] or vim.diagnostic.severity.WARN,
          })
        end
      end
    end
    return diagnostics
  end,
}
