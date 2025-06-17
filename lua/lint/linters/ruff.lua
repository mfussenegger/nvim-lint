local function get_file_name()
  return vim.api.nvim_buf_get_name(0)
end

local error = vim.diagnostic.severity.ERROR
local severities = {
  ["F821"] = error, -- undefined name `name`
  ["E902"] = error, -- `IOError`
  ["E999"] = error, -- `SyntaxError`
}

local function get_severity(result_code, result_message)
  local severity = severities[result_code]
  if severity then
    return severity
  end
  if result_message:find("^SyntaxError:") then
    return error
  end
  return vim.diagnostic.severity.WARN
end

return {
  cmd = "ruff",
  stdin = true,
  args = {
    "check",
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
      local diagnostic = {
        message = result.message,
        col = result.location.column - 1,
        end_col = result.end_location.column - 1,
        lnum = result.location.row - 1,
        end_lnum = result.end_location.row - 1,
        code = result.code,
        severity = get_severity(result.code, result.message),
        source = "ruff",
      }
      table.insert(diagnostics, diagnostic)
    end
    return diagnostics
  end,
}
