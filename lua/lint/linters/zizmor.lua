local severities = {
  High = vim.diagnostic.severity.ERROR,
  Medium = vim.diagnostic.severity.WARN,
  Low = vim.diagnostic.severity.INFO,
}

return {
  cmd = "zizmor",
  args = { "--format", "json" },
  stdin = false,
  ignore_exitcode = true,

  parser = function(output, _)
    local items = {}

    if output == "" then
      return items
    end

    local decoded = vim.json.decode(output) or {}

    for _, diag in ipairs(decoded) do
      for _, loc in ipairs(diag.locations) do
        local location = loc.concrete.location
        local msg = string.format("%s (%s)\nMore Info: %s", loc.symbolic.annotation, diag.desc, diag.url)
        table.insert(items, {
          source = "zizmor",
          lnum = location.start_point.row,
          col = location.start_point.column,
          end_lnum = location.end_point.row,
          end_col = location.end_point.column,
          message = msg,
          code = diag.ident,
          severity = assert(
            severities[diag.determinations.severity],
            "missing mapping for severity " .. diag.determinations.severity
          ),
        })
      end
    end

    return items
  end,
}
