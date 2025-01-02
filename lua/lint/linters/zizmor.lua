local severities = {
  High = vim.diagnostic.severity.ERROR,
  Medium = vim.diagnostic.severity.WARN,
}

return {
  cmd = "zizmor",
  args = { "--format", "json" },
  stdin = false,
  ignore_exitcode = true, -- 14

  parser = function(output, _)
    local items = {}

    if output == "" then
      return items
    end

    local decoded = vim.json.decode(output) or {}
    local bufpath = vim.fn.expand("%:p")

    for _, diag in ipairs(decoded) do
      if diag.locations[1].symbolic.key.Local.path == bufpath then
        table.insert(items, {
          source = "zizmor",
          lnum = diag.locations[1].concrete.location.start_point.row,
          col = diag.locations[1].concrete.location.start_point.column,
          end_lnum = diag.locations[1].concrete.location.end_point.row - 1,
          end_col = diag.locations[1].concrete.location.end_point.column,
          message = diag.desc,
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
