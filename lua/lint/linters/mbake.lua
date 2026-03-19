return {
  cmd = "mbake",
  stdin = false,
  append_fname = true,
  stream = "stdout",
  ignore_exitcode = true,
  args = {
    "validate",
  },
  parser = function(output, bufnr)
    local diagnostics = {}

    for _, line in ipairs(vim.split(output, "\n")) do
      local file, lnum, message = line:match("%s*([^:]+):(%d+):%s*(.+)")

      if file and lnum and message then
        message = message:gsub("^%*+%s*", ""):gsub("%s*Stop%.$", "")

        table.insert(diagnostics, {
          lnum = tonumber(lnum) - 1,
          col = 0,
          severity = vim.diagnostic.severity.ERROR,
          source = "mbake",
          message = vim.trim(message),
        })
      end
    end

    return diagnostics
  end,
}
