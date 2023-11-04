local function get_file_name()
  return vim.api.nvim_buf_get_name(0)
end

return {
  cmd = "ruff",
  stdin = true,
  args = {
    "--force-exclude",
    "--quiet",
    "--stdin-filename",
    get_file_name,
    "--no-fix",
    "--output-format",
    "json",
    "-",
  },
  ignore_exitcode = true,
  stream = "stdout",
  parser = function(output)
    local diagnostics = {}
    local ok, results = pcall(vim.json.decode, output)
    if not ok then
      return diagnostics
    end
    for _, result in ipairs(results or {}) do
      local err = {
        message = result.message,
        col = result.location.column - 1,
        end_col = result.end_location.column - 1,
        lnum = result.location.row - 1,
        end_lnum = result.end_location.row - 1,
        code = result.code,
        severity = vim.diagnostic.severity.WARN,
      }
      table.insert(diagnostics, err)
    end
    return diagnostics
  end,
}
