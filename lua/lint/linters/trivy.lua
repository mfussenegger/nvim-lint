-- Map trivy severity to vim.diagnostic severity
local severity_map = {
  ["LOW"] = vim.diagnostic.severity.INFO,
  ["MEDIUM"] = vim.diagnostic.severity.WARN,
  ["HIGH"] = vim.diagnostic.severity.ERROR,
}

return {
  cmd = "trivy",
  stdin = false,
  append_fname = true,
  -- FIXME: '--scanners config' is deprecated in favor of '--scanners misconfig'
  -- NOTE: excluding '-q/--quiet' flag to receive log on stderr before the JSON on stdout.
  --       The log may contain errors and warnings that can be used to notify the user this script
  --       needs maintenance.
  args = { "--scanners", "config", "--format", "json", "fs" },
  stream = "stdout",
  ignore_exitcode = false,
  parser = function(
    output, -- output from trivy (a JSON string)
    bufnr -- nvim buffer number. Used to choose the correct Result from the JSON output
  )
    local diagnostics = {}

    -- TODO: Parse log messages from trivy that appear before the JSON.  Register any ERRORS or
    --       WARNINGS as diagnostics so someone will know to make future updates to this script.
    -- NOTE: Don't know how to get access to both stderr and stdout, so unable to address this
    --       TODO.  Setting stream = 'both' only yields the stdout stream.

    -- parse trivy output JSON
    --
    -- fields used:
    -- {
    --   "Results": [
    --     "Target": "<file path>",
    --     "Misconfigurations": [
    --       "ID": "<nvim-lint code>",
    --       "Title": "<title>",
    --       "Description": "<description>",
    --       "Severity": "<LOW|MEDIUM|HIGH>",
    --       "CauseMetadata": {
    --         "StartLine": <line number>,
    --         "EndLine": <line number>,
    --       }
    --     ]
    --   ]
    -- }
    local ok, decoded = pcall(vim.json.decode, output)
    if not ok then
      return diagnostics
    end

    local fpath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")

    for _, result in ipairs(decoded and decoded.Results or {}) do
      -- If trivy returns Results for multiple files, only consider those for bufnr
      if result.Target == fpath then
        for _, misconfig in ipairs(result.Misconfigurations or {}) do
          -- FIXME: check all misconfig fields for nil before accesing
          local err = {
            source = "trivy",
            message = string.format("%s %s", misconfig.Title, misconfig.Description),
            col = misconfig.CauseMetadata.StartLine, -- FIXME: trivy doesn't provide col info
            end_col = misconfig.CauseMetadata.EndLine, -- FIXME: trivy doesn't provide col info
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
