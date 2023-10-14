local binary_name = "eslint"

local severities = {
  vim.diagnostic.severity.WARN,
  vim.diagnostic.severity.ERROR,
}

local diagnostic_translate_map = {
  column = "col",
  endColumn = "end_col",
  endLine = "end_lnum",
  line = "lnum",
  message = "message",
  ruleId = "code",
  severity = "severity",
}

return require('lint.util').inject_cmd_exe({
  cmd = function()
    local local_binary = vim.fn.fnamemodify('./node_modules/.bin/' .. binary_name, ':p')
    local stat = vim.loop.fs_stat(local_binary)

    if stat then
      return local_binary
    end

    return binary_name
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
  parser = function(output)
    local success, decodedData = pcall(vim.json.decode, output)
    local json = decodedData and decodedData[1] and decodedData[1].messages or {}
    local diagnostics = {}

    if success and #json > 0 then
      for _, json_diagnostic in ipairs(json) do
        local diagnostic = {}

        -- Translate the json diagnostic to a diagnostic.
        for json_key, diagnostic_key in pairs(diagnostic_translate_map) do
          if json_diagnostic[json_key] ~= vim.NIL then
            if json_key == 'severity' then
              diagnostic[diagnostic_key] = severities[json_diagnostic[json_key]]
            elseif type(json_diagnostic[json_key]) == "number" then
              diagnostic[diagnostic_key] = json_diagnostic[json_key] - 1
            else
              diagnostic[diagnostic_key] = json_diagnostic[json_key]
            end
          end
        end

        -- Ensure that we have a diagnostic with `col` and `lnum` set, since
        -- they are required.
        if diagnostic.col and diagnostic.lnum then
          table.insert(
            diagnostics,
            vim.tbl_extend("force", diagnostic, { source = binary_name })
          )
        end
      end
    end

    return diagnostics
  end
})
