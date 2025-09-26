local LINTER_NAME = "gitleaks"

return function()
  ---Arguments to pass to detect-secrets
  local args = { "--report-format=json", "--report-path=-", "--exit-code=0" }

  ---Baseline file (use the baseline name in the example at https://github.com/gitleaks/gitleaks?tab=readme-ov-file#creating-a-baseline)
  ---@type string
  local baseline = vim.fn.findfile("gitleaks-report.json", ".;")

  if baseline ~= "" then
    table.insert(args, "--baseline-path")
    table.insert(args, baseline)
  end

  -- Command
  table.insert(args, "file")

  ---@type lint.Linter
  return {
    name = LINTER_NAME,
    cmd = "gitleaks",
    stdin = false,
    append_fname = true,
    args = args,
    stream = "stdout",
    ignore_exitcode = false,
    parser = function(output, bufnr, _)
      local decoded_output = vim.json.decode(output)

      ---Diagnostics generated with the output of 'gitleaks'
      ---@type vim.Diagnostic[]
      local diagnostics = {}

      for _, leak in ipairs(decoded_output) do
        ---@type vim.Diagnostic
        local new_diagnostic = {
          bufnr = bufnr,
          lnum = leak.StartLine - 1,
          end_lnum = leak.EndLine - 1,
          col = leak.StartColumn - 1,
          end_col = leak.EndColumn - 1,
          source = LINTER_NAME,
          message = leak.Description,
        }

        table.insert(diagnostics, new_diagnostic)
      end

      return diagnostics
    end,
  }
end
