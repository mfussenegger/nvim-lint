local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  refactor = vim.diagnostic.severity.INFO,
  convention = vim.diagnostic.severity.HINT,
}

return {
  cmd = 'checkov',
  stdin = true,
  args = {
    '-f',
    vim.api.nvim_buf_get_name(0),
    '-o',
    'json'
  },
  stream = 'stdout',
  ignore_exitcode = true,
  parser = function(output)
    if output == '' then
      return {}
    end
    local decoded = vim.fn.json_decode(output)
    local diagnostics = {}
    local source = decoded["check_type"]

    -- if they are no results, don't do anything.
    if decoded["results"] == nil then
      return {}
    end

    if decoded["results"]["failed_checks"] then
      for _, check in ipairs(decoded["results"]["failed_checks"]) do
        local id = check["check_id"]
        local name = check["check_name"]
        local range = check["file_line_range"]
        local guideline = check["guideline"]

        local sv = severities.warning
        table.insert(diagnostics, {
          lnum = range[1],
          col = 0,
          end_lnum = range[2],
          end_col = 0,
          severity = sv,
          message = name .. ": " .. id .. "\n" .. guideline,
          source = "checkov: " .. source,
        })
      end
    end
    return diagnostics
  end
}

