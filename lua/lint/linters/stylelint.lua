local severities = {
  warning = vim.diagnostic.severity.WARN,
  error = vim.diagnostic.severity.ERROR,
}

return require('lint.util').inject_cmd_exe({
  cmd = function()
    local local_stylelint = vim.fn.fnamemodify("./node_modules/.bin/stylelint", ":p")
    local stat = vim.loop.fs_stat(local_stylelint)
    if stat then
      return local_stylelint
    end
    return "stylelint"
  end,
  stdin = true,
  args = {
    "-f",
    "json",
    "--stdin",
    "--stdin-filename",
    function()
      return vim.fn.expand("%:p")
    end,
  },
  stream = "stdout",
  ignore_exitcode = true,
  parser = function (output)
    local status, decoded = pcall(vim.json.decode, output)
    if status then
      decoded = decoded[1]
    else
      decoded = {
        warnings = {
          {
            line = 1,
            column = 1,
            text = "Stylelint error, run `stylelint " .. vim.fn.expand("%") .. "` for more info.",
            severity = "error",
            rule = "none",
          },
        },
        errored = true,
      }
    end
    local diagnostics = {}
    if decoded.errored then
      for _, message in ipairs(decoded.warnings) do
        table.insert(diagnostics, {
          lnum = message.line - 1,
          col = message.column - 1,
          end_lnum = message.line - 1,
          end_col = message.column - 1,
          message = message.text,
          code = message.rule,
          user_data = {
            lsp = {
              code = message.rule,
            }
          },
          severity = severities[message.severity],
          source = "stylelint",
        })
      end
    end
    return diagnostics
  end
})
