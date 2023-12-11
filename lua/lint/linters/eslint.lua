local binary_name = "eslint"
local severities = {
  vim.diagnostic.severity.WARN,
  vim.diagnostic.severity.ERROR,
}

local function get_local_binary()
  local files = vim.fs.find({ 'node_modules' }, { upward = true, limit = 3 })
  for _, dir in ipairs(files) do
    local path = dir .. '/.bin/' .. binary_name
    local stat = vim.uv.fs_stat(path)
    if stat then
      return path
    end
  end
end

return {
  cmd = function()
    local local_binary = get_local_binary()
    return local_binary or binary_name
  end,
  args = {
    '--format',
    'json',
    '--stdin',
    '--stdin-filename',
    function() return vim.api.nvim_buf_get_name(0) end,
  },
  stdin = true,
  stream = 'stdout',
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
          message = "Could not parse linter output due to: " .. data .. "\noutput: " .. output
        }
      }
    end
    -- See https://eslint.org/docs/latest/use/formatters/#json
    local diagnostics = {}
    for _, result in ipairs(data or {}) do
      for _, msg in ipairs(result.messages or {}) do
        table.insert(diagnostics, {
          lnum = msg.line and (msg.line - 1) or 0,
          end_lnum = msg.endLine and (msg.endLine - 1) or nil,
          col = msg.column and (msg.column - 1) or 0,
          end_col = msg.endColumn and (msg.endColumn - 1) or nil,
          message = msg.message,
          code = msg.ruleId,
          severity = severities[msg.severity],
          source = binary_name
        })
      end
    end
    return diagnostics
  end
}
