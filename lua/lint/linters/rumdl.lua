local function get_file_name()
  return vim.api.nvim_buf_get_name(0)
end

local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  info = vim.diagnostic.severity.INFO,
}

return {
  cmd = "rumdl",
  args = { "check", "--stdin-filename", get_file_name, "--output", "json", "-" },
  stdin = true,
  stream = "stderr",
  ignore_exitcode = true,
  parser = function(output)
    local decoded = vim.json.decode(output)
    local diagnostics = {}

    for _, item in ipairs(decoded) do
      table.insert(diagnostics, {
        lnum = item.line - 1,
        col = item.column - 1,
        severity = assert(severities[item.severity], "missing mapping for severity " .. item.severity),
        message = item.message,
        source = "rumdl",
        code = item.rule,
      })
    end

    return diagnostics
  end,
}
