local binary_name = "markuplint"

local severity_map = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
}

return {
  cmd = function()
    local local_binary = vim.fn.fnamemodify("./node_modules/.bin/" .. binary_name, ":p")
    return vim.loop.fs_stat(local_binary) and local_binary or binary_name
  end,
  args = { "--format", "JSON" },
  stdin = false,
  stream = "stdout",
  ignore_exitcode = true,
  parser = function(output, bufnr)
    if vim.trim(output) == "" then
      return {}
    end

    local decode_opts = { luanil = { object = true, array = true } }
    local ok, data = pcall(vim.json.decode, output, decode_opts)
    if not ok then
      return {
        {
          bufnr = bufnr,
          lnum = 0,
          col = 0,
          message = "Could not parse markuplint output due to: " .. data .. "\noutput: " .. output,
        },
      }
    end

    local diagnostics = {}
    for _, result in ipairs(data or {}) do
      table.insert(diagnostics, {
        lnum = result.line and result.line - 1 or 0,
        col = result.col and result.col - 1 or 0,
        message = result.message,
        code = result.ruleId,
        severity = severity_map[result.severity] or vim.diagnostic.severity.ERROR,
        source = "markuplint",
      })
    end
    return diagnostics
  end,
}
