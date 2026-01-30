local severities = {
  vim.diagnostic.severity.HINT,
  vim.diagnostic.severity.INFO,
  vim.diagnostic.severity.WARN,
  vim.diagnostic.severity.ERROR,
}

local no_ruleset_found_msg = [[Spectral could not find a ruleset.
Please define a .spectral file in the current working directory or override the linter args to provide the path to a ruleset.]]

return {
  cmd = 'spectral',
  stdin = false,
  append_fname = true,
  args = { "lint", "-f", "json", },
  stream = "both",
  ignore_exitcode = true,
  parser = function(output, _)
    -- inform user if no ruleset has been found
    if string.find(output, "No ruleset has been found") ~= nil then
      vim.notify(no_ruleset_found_msg, vim.log.levels.WARN)
      return {}
    end

    -- spectral returns `[]No results with a severity of 'error' found!` on no errors, which is not valid JSON
    if string.find(output, "No results with a severity of 'error' found!") ~= nil then
      return {}
    end

    local result = vim.json.decode(output)

    -- prevent warning on yaml files without supported schema
    if result[1].code == "unrecognized-format" then
      return {}
    end

    local items = {}
    local bufpath = vim.fn.expand('%:p')
    for _, diag in ipairs(result) do
      if diag.source == bufpath then
        table.insert(items, {
          source = "spectral",
          severity = severities[diag.severity + 1],
          code = diag.code,
          message = diag.message,
          lnum = diag.range.start.line + 1,
          end_lnum = diag.range["end"].line + 1,
          col = diag.range.start.character + 1,
          end_col = diag.range["end"].character + 1,
        })
      end
    end

    return items
  end,
}
