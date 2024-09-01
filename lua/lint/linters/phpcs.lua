local severities = {
  ERROR = vim.diagnostic.severity.ERROR,
  WARNING = vim.diagnostic.severity.WARN,
}

local bin ='phpcs'

return {
  cmd = function()
    local local_bin = vim.fn.fnamemodify('vendor/bin/' .. bin, ':p')
    return vim.loop.fs_stat(local_bin) and local_bin or bin
  end,
  stdin = true,
  args = {
    '-q',
    '--report=json',
    '-', -- need `-` at the end for stdin support
  },
  ignore_exitcode = true,
  parser = function(output, _)
    if vim.trim(output) == '' or output == nil then
      return {}
    end

    local json_start = output:find("{")
    local json_end = output:find("}%s")

    if not json_start or not json_end then
      vim.notify("No complete JSON found in output")
      return {}
    end

    local json_part = output:sub(json_start, json_end)

    local success, decoded = pcall(vim.json.decode, json_part)
    if not success then
      vim.notify("Failed to decode JSON")
      return {}
    end

    local diagnostics = {}

    for file_path, file_data in pairs(decoded['files']) do
      local messages = file_data['messages']

      for _, msg in ipairs(messages or {}) do
        print(msg.type)
        table.insert(diagnostics, {
          lnum = msg.line - 1,
          end_lnum = msg.line - 1,
          col = msg.column - 1,
          end_col = msg.column - 1,
          message = msg.message,
          code = msg.source,
          source = bin,
          severity = assert(severities[msg.type],
            'missing mapping for severity ' .. msg.type),
        })
      end
    end

    return diagnostics
  end
}
