local severities = {
  Error = vim.diagnostic.severity.ERROR,
  Warning = vim.diagnostic.severity.WARN,
}

return {
  cmd = "sqruff",
  stdin = true,
  args = {
    "lint",
    "--format=json",
    "-",
  },
  ignore_exitcode = true,
  parser = function(output, _)
    if vim.trim(output) == "" or output == nil then
      return {}
    end


    local decoded = vim.json.decode(output)
    local diagnostics = {}
    local messages = decoded["<string>"]

    for _, msg in ipairs(messages or {}) do
      table.insert(diagnostics, {
        lnum = msg.range.start.line - 1,
        end_lnum = msg.range["end"].line - 1,
        col = msg.range.start.character - 1,
        end_col = msg.range["end"].character - 1,
        message = msg.message,
        code = msg.source, -- TODO: https://github.com/quarylabs/sqruff/issues/1219
        source = msg.source,
        severity = assert(severities[msg.severity], "missing mapping for severity " .. msg.severity),
      })
    end

    return diagnostics
  end,
}
