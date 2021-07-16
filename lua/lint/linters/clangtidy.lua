local pattern = [[([^:]*):(%d+):(%d+): (%w+): ([^[]+)]]

local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
}

return {
  cmd = "clang-tidy",
  stdin = false,
  args = { "--quiet" },
  parser = function(output, bufnr)
    local buffer_path = vim.api.nvim_buf_get_name(bufnr)
    local diagnostics = {}

    for line in vim.gsplit(output, "\n") do
      for file, lineno, colno, severity, msg in line:gmatch(pattern) do
        if file ~= buffer_path then
          break
        end

        local range = {
          line = tonumber(lineno) - 1,
          character = tonumber(colno) - 1,
        }
        table.insert(diagnostics, {
          range = {
            ["start"] = range,
            ["end"] = range,
          },
          severity = severities[severity] or severities.warning,
          message = msg,
        })
      end
    end

    return diagnostics
  end,
}
