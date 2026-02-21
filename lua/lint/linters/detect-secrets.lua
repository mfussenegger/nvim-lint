local name = "detect-secrets"

return function()
  local args = { "scan" }

  -- See https://github.com/Yelp/detect-secrets?tab=readme-ov-file#examples)
  local baseline = vim.fn.findfile(".secrets.baseline", ".;")

  if baseline ~= "" then
    table.insert(args, "--baseline")
    table.insert(args, baseline)
  end

  ---@type lint.Linter
  return {
    name = name,
    cmd = name,
    stdin = false,
    append_fname = true,
    args = args,
    stream = "stdout",
    ignore_exitcode = false,
    parser = function(output, _, _)
      local decoded_output = vim.json.decode(output)
      local diagnostics = {}

      for _, leaks in pairs(decoded_output.results) do
        for _, leak in ipairs(leaks) do
          ---@type vim.Diagnostic.Set
          local new_diagnostic = {
            col = 0,
            source = name,
            lnum = leak.line_number - 1, -- 'detect-secrets' uses 1-indexed line numbers
            message = leak.type,
          }
          table.insert(diagnostics, new_diagnostic)
        end
      end

      return diagnostics
    end,
  }
end
