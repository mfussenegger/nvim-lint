---@type { [string]: vim.diagnostic.Severity }
local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  info = vim.diagnostic.severity.INFO,
  hint = vim.diagnostic.severity.HINT,
}

---@param diagnostics vim.Diagnostic[]
---@param output table
---@param level string
---@return nil
local function insert_diagnostics(diagnostics, output, level)
  local results = output[level].results
  for _, result in pairs(results or {}) do
    table.insert(diagnostics, {
      lnum = result.line - 1,
      col = 0,
      severity = severities[level],
      message = result.message,
      source = 'lint-openapi',
      code = result.rule
    })
  end
end

---@type lint.Linter
return {
  name = 'lint-openapi',
  cmd = 'lint-openapi',
  args = { '--json' },
  append_fname = true,
  ignore_exitcode = true,
  parser = function(output, bufnr, _)
    if vim.trim(output) == '' then
      return {}
    end

    local allowed_filenames = {
      ['openapi.json'] = true,
      ['openapi.yaml'] = true,
    }

    local filename = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
    if not allowed_filenames[filename] then
      return {}
    end

    local decoded = vim.fn.json_decode(output)

    local diagnostics = {}
    insert_diagnostics(diagnostics, decoded, 'error')
    insert_diagnostics(diagnostics, decoded, 'warning')
    insert_diagnostics(diagnostics, decoded, 'info')
    insert_diagnostics(diagnostics, decoded, 'hint')
    return diagnostics
  end
}
