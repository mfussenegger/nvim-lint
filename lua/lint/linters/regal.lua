-- https://github.com/StyraInc/regal

local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
}

return {
  cmd = "regal",
  args = { "lint", "--format", "json" },
  stdin = false,
  append_fname = true,
  stream = "stdout",
  ignore_exitcode = true,
  parser = function(output, _)
    local diagnostics = {}

    if output == "" then
      return diagnostics
    end

    local decoded = vim.json.decode(output)
    if decoded ~= nil then
      for _, item in ipairs(decoded.violations or {}) do
        local end_col = item.location.text ~= nil and item.location.text:len() + 1 or item.location.col
        local lnum = math.max(item.location.row - 1, 0)

        table.insert(diagnostics, {
          lnum = lnum,
          end_lnum = lnum,
          col = math.max(item.location.col - 1, 0),
          end_col = end_col,
          severity = severities[item.level] or severities.error,
          source = "[regal] " .. item.category,
          message = item.description,
          code = item.title,
        })
      end
    end

    return diagnostics
  end,
}
