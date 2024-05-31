local severity_map = {
  ["LOW"] = vim.diagnostic.severity.INFO,
  ["MEDIUM"] = vim.diagnostic.severity.WARN,
  ["HIGH"] = vim.diagnostic.severity.ERROR,
}


return {
  cmd = "trivy",
  stdin = false,
  append_fname = true,
  args = { "--scanners", "misconfig", "--format", "json", "fs" },
  stream = "stdout",
  ignore_exitcode = false,
  parser = function(output, bufnr)
    local diagnostics = {}

    -- example output:
    -- {
    --   "Results": [
    --     "Target": "<file path>",
    --     "Misconfigurations": [
    --        {
    --          "ID": "<nvim-lint code>",
    --          "Title": "<title>",
    --          "Description": "<description>",
    --          "Severity": "<LOW|MEDIUM|HIGH>",
    --          "CauseMetadata": {
    --            "StartLine": <line number>,
    --            "EndLine": <line number>,
    --          }
    --        }
    --     ]
    --   ]
    -- }
    local decoded = vim.json.decode(output)
    local fpath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")

    for _, result in ipairs(decoded and decoded.Results or {}) do
      -- trivy can return Results for other files; only report for current buffer
      --
      if result.Target == fpath then
        for _, misconfig in ipairs(result.Misconfigurations or {}) do
          local title = misconfig.Title or "<No Title>"
          local description = misconfig.Description or "<No Description>"
          local id = misconfig.ID or "<No ID>"
          local md = misconfig.CauseMetadata or {}
          local lnum = md.StartLine and md.StartLine - 1 or 0
          local end_lnum = md.EndLine and md.EndLine - 1 or 0
          table.insert(diagnostics, {
            source = "trivy",
            message = string.format("%s: %s", title, description),
            col = 0,
            end_col = 0,
            lnum = lnum,
            end_lnum = end_lnum,
            code = id,
            severity = severity_map[misconfig.Severity] or vim.diagnostic.severity.WARN,
          })
        end
      end
    end
    return diagnostics
  end,
}
