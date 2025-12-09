local LINTER_NAME = "gitleaks"

---@type lint.Linter
return {
  name = LINTER_NAME,
  cmd = "gitleaks",
  stdin = false,
  append_fname = true,
  args = { "--report-format=json", "--report-path=-", "--exit-code=0", "file" },
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
