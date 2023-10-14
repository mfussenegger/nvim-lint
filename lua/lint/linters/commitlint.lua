return {
  cmd = "commitlint",
  stdin = true,
  args = {},
  ignore_exitcode = true,
  parser = function(output)
    local diagnostics = {}

    local result = vim.fn.split(output, "\n")

    for _, line in ipairs(result) do
      local label = line:sub(1, 3)
      if label == "✖" then
        if not string.find(line, "found") then
          table.insert(diagnostics, {
            source = "commitlint",
            lnum = 0,
            col = 0,
            severity = vim.diagnostic.severity.ERROR,
            message = vim.fn.split(line, "   ")[2],
          })
        end
      end
    end
    return diagnostics
  end,
}
