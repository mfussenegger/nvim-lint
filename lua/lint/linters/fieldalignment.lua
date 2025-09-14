local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  ignored = vim.diagnostic.severity.INFO,
}

return {
  cmd = "fieldalignment",
  stdin = false,
  args = {
    "-json",
  },
  ignore_exitcode = true,
  parser = function(output)
    if output == "" then
      return {}
    end
    local decoded = vim.json.decode(output, { luanil = { object = true, array = true } })
    local diagnostics = {}
    for _, issues in pairs(decoded) do
      for _, issue_list in pairs(issues) do
        for _, issue in ipairs(issue_list) do
          local pos = issue.posn
          local _, lnum, col = pos:match("^(.+):(%d+):(%d+)$")
          lnum = tonumber(lnum) or 1
          col = tonumber(col) or 1
          local message = issue.message
          if issue.suggested_fixes and #issue.suggested_fixes > 0 then
            local fix = issue.suggested_fixes[1]
            if fix.edits and #fix.edits > 0 then
              local suggested_fix = fix.edits[1].new
              suggested_fix = suggested_fix:gsub("\n", "\n\t"):gsub("\t", "  ")
              message = message .. "\nSuggested struct:\n" .. suggested_fix
            end
          end
          table.insert(diagnostics, {
            lnum = lnum - 1,
            col = col - 1,
            end_lnum = lnum - 1,
            end_col = col - 1,
            severity = severities.warning,
            message = message,
            source = "fieldalignment",
          })
        end
      end
    end
    return diagnostics
  end,
}
