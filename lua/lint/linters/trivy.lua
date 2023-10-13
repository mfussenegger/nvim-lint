local severity_map = {
  ["LOW"] = vim.diagnostic.severity.INFO,
  ["MEDIUM"] = vim.diagnostic.severity.WARN,
  ["HIGH"] = vim.diagnostic.severity.ERROR,
}

return {
  cmd = "trivy",
  stdin = false,
  append_fname = true,
  args = { "--scanners", "config", "--format", "json", "fs" },
  stream = "stdout",
  ignore_exitcode = false,
  parser = function(output, bufnr)
    local diagnostics = {}
    local ok, decoded = pcall(vim.json.decode, output)
    if not ok then
      return diagnostics
    end
    local fpath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
    for _, result in ipairs(decoded and decoded.Results or {}) do
      if result.Target == fpath then
        for _, misconfig in ipairs(result.Misconfigurations) do
          local err = {
            source = "trivy",
            message = string.format("%s %s", misconfig.Title, misconfig.Description),
            col = misconfig.CauseMetadata.StartLine,
            end_col = misconfig.CauseMetadata.EndLine,
            lnum = misconfig.CauseMetadata.StartLine - 1,
            end_lnum = misconfig.CauseMetadata.EndLine - 1,
            code = misconfig.ID,
            severity = severity_map[misconfig.Severity],
          }
          table.insert(diagnostics, err)
        end
      end
    end
    return diagnostics
  end,
}
