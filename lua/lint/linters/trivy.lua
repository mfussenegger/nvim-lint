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
  -- NOTE: excluding '-q/--quiet' flag to receive log on stderr before the JSON on stdout.
  --       The log may contain errors and warnings that can be used to notify the user this script
  --       needs maintenance.
  args = { "--scanners", "misconfig", "--format", "json", "fs" },
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

    -- If these are not present, drop/skip the Misconfiguration
    -- NOTE: Could also default and override the vim.diagnostic.severity
    local required_misconfig_fields = { "Severity" }

    for _, result in ipairs(decoded and decoded.Results or {}) do
      -- If trivy returns Results for multiple files, only consider those for bufnr
      if result.Target == fpath then
        for _, misconfig in ipairs(result.Misconfigurations or {}) do
          -- skip this misconfiguration if any required fields are missing
          for _, field in ipairs(required_misconfig_fields or {}) do
            if not misconfig[field] then
              goto next_misconfig
            end
          end

          local title = "<No Title>"
          if misconfig.Title then
            title = misconfig.Title
          end

          local description = "<No Description>"
          if misconfig.Description then
            description = misconfig.Description
          end

          local id = "<No ID>"
          if misconfig.ID then
            id = misconfig.ID
          end

          -- default start posi to first line, then override if StartLine exist
          local lnum = 0
          if misconfig.CauseMetadata and misconfig.CauseMetadata.StartLine then
            lnum = misconfig.CauseMetadata.StartLine - 1
          end

          -- default end posi to start posi, then override if EndLine exist
          local end_lnum = lnum
          if misconfig.CauseMetadata and misconfig.CauseMetadata.EndLine then
            end_lnum = misconfig.CauseMetadata.EndLine - 1
          end

          table.insert(diagnostics, {
            source = "trivy",
            message = string.format("%s: %s", title, description),
            col = 0, -- trivy doesn't provide col info; nvim-lint defaults to 0
            end_col = 0, -- trivy doesn't provide col info; nvim-lint defaults to 0
            lnum = lnum,
            end_lnum = end_lnum,
            code = id,
            severity = severity_map[misconfig.Severity],
          })

          ::next_misconfig::
         end
      end
    end

    return diagnostics
  end,
}
