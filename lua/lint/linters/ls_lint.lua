return {
  cmd = "ls-lint",
  args = {
    -- sends warnings to stdout to avoid failure when '.ls-lint.yml' is missing
    "-warn",
    "-error-output-format",
    "json",
    function()
      -- requires relative file path:
      -- https://github.com/loeffel-io/ls-lint/issues/321
      return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
    end,
  },
  stdin = false,
  stream = "stdout",
  ignore_exitcode = true,
  append_fname = false,
  parser = function(output)
    local decoded = vim.json.decode(output)
    local diagnostics = {}

    for filename, result in pairs(decoded) do
      for _, rules in pairs(result) do
        local msg = string.format("File %s should use one of: %s", filename, table.concat(rules, ", "))
        table.insert(diagnostics, {
          lnum = 0,
          col = 0,
          message = msg,
          source = "ls-lint",
          severity = vim.diagnostic.severity.WARN,
        })
      end
    end

    return diagnostics
  end,
}
