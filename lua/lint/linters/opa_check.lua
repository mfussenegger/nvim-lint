-- https://github.com/open-policy-agent/opa
return {
  cmd = "opa",
  args = { "check", "--strict", "--format", "json" },
  stdin = false,
  append_fname = true,
  stream = "stderr",
  ignore_exitcode = true,
  parser = function(output, _)
    local diagnostics = {}

    if output == "" then
      return diagnostics
    end

    local decoded = vim.json.decode(output)
    if decoded ~= nil then
      for _, item in ipairs(decoded.errors or {}) do
        local lnum = item.location.row - 1

        table.insert(diagnostics, {
          lnum = lnum,
          end_lnum = lnum,
          col = item.location.col - 1,
          end_col = item.location.col,
          severity = vim.diagnostic.severity.ERROR,
          source = "opa_check",
          message = item.message,
          code = item.code,
        })
      end
    end

    return diagnostics
  end,
}
