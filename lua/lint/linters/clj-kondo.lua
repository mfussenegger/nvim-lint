local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
}

local function get_file_name()
  return vim.api.nvim_buf_get_name(0)
end

return {
  cmd = 'clj-kondo',
  stdin = true,
  stream = 'stdout',
  ignore_exitcode = true,
  args = {
    '--config', '{:output {:format :json}}', '--filename', get_file_name, '--lint', '-',
  },
  parser = function(output)
    local decoded = vim.json.decode(output) or {}
    local findings = decoded.findings
    local diagnostics = {}

    for _, finding in pairs(findings or {}) do
      table.insert(diagnostics, {
        lnum = finding.row - 1,
        col = finding.col,
        end_lnum = finding.row - 1,
        end_col = finding.col,
        severity = assert(severities[finding.level], 'missing mapping for severity ' .. finding.level),
        message = finding.message,
      })
    end

    return diagnostics
  end,
}
