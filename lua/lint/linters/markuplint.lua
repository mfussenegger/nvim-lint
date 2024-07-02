local binary_name = "markuplint"

local severity_map = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
}

return {
  cmd = function(opts)
    local local_binary;
    if opts.cwd then
      local_binary = vim.fn.fnamemodify(opts.cwd .. '/node_modules/.bin/' .. binary_name, ':p')
    else
      local_binary = vim.fn.fnamemodify('./node_modules/.bin/' .. binary_name, ':p')
    end
    return vim.loop.fs_stat(local_binary) and local_binary or binary_name
  end,
  args = { "--format", "JSON" },
  stdin = false,
  stream = "stdout",
  ignore_exitcode = true,
  parser = function(output)
    if vim.trim(output) == "" then
      return {}
    end

    local decode_opts = { luanil = { object = true, array = true } }
    local data = vim.json.decode(output, decode_opts)

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
