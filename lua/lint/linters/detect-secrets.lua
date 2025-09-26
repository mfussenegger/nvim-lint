-- Constants
local LINTER_NAME = "detect-secrets"

return function()
  ---Arguments to pass to detect-secrets
  local args = { "scan" }

  ---Baseline file (use the baseline name in the example at https://github.com/Yelp/detect-secrets?tab=readme-ov-file#examples)
  ---@type string
  local baseline = vim.fn.findfile(".secrets.baseline", ".;")

  if baseline ~= "" then
    table.insert(args, "--baseline")
    table.insert(args, baseline)
  end

  ---@type lint.Linter
  return {
    name = LINTER_NAME,
    cmd = "detect-secrets",
    stdin = false,
    append_fname = true,
    args = args,
    stream = "stdout",
    ignore_exitcode = false,
    parser = function(output, bufnr, _)
      local decoded_output = vim.json.decode(output)

      ---Diagnostics generated with the output of detect-secrets
      ---@type vim.Diagnostic[]
      local diagnostics = {}

      for _, leaks in pairs(decoded_output.results) do
        for _, leak in ipairs(leaks) do
          -- 'detect-secrets' does not provide the line number, so we need to get it from the buffer
          local line = vim.api.nvim_buf_get_lines(bufnr, leak.line_number - 1, leak.line_number, true)[1]

          ---@type vim.Diagnostic
          local new_diagnostic = {
            bufnr = bufnr,
            col = #line - 1,
            source = LINTER_NAME,
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
