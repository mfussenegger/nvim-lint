local M = {
  cmd = "pmd",
  stdin = false,
  args = {
    "check",
    "--format",
    "json",
    "--rulesets",
    "category/java/bestpractices.xml",
    "--dir",
  },
  ignore_exitcode = true,
  parser = function(output, linter_bufnr)
    local diagnostics = {}

    if not output then
      return diagnostics
    end

    local decoded = vim.json.decode(output) or {}

    local files = decoded.files or {}

    for _, file in ipairs(files) do
      local file_bufnr = vim.uri_to_bufnr(vim.uri_from_fname(vim.fs.abspath(file.filename)))

      -- TODO: This check can be removed, once nvim-lint supports multiple
      -- buffers.
      -- https://github.com/mfussenegger/nvim-lint/issues/716
      if linter_bufnr == file_bufnr then
        for _, violation in ipairs(file.violations) do
          local code = violation.ruleset .. "/" .. violation.rule
          table.insert(diagnostics, {
            source = "pmd",
            lnum = violation.beginline - 1,
            col = violation.begincolumn - 1,
            end_lnum = violation.end_lnum and violation.end_lnum - 1,
            end_col = violation.endcolumn and violation.endcolumn - 1,
            code = code,
            message = violation.description,
            severity = violation.priority and math.max(1, violation.priority - 1),
            bufnr = file_bufnr,
            user_data = {
              lsp = {
                code = code,
              },
              url = violation.externalInfoUrl,
            },
          })
        end
      end
    end

    return diagnostics
  end,
}

return M
