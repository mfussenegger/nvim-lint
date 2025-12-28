return {
  cmd = 'proselint',
  stdin = false,
  args = { 'check', '--output-format=json' },
  ignore_exitcode = true,
  parser = function(output)
    if output == '' then
      return {}
    end
    local json_output = vim.json.decode(output, { luanil = { object = true } })
    local diagnostics = {}
    local file_key = vim.tbl_keys(json_output.result)[1]
    local results = json_output.result[file_key].diagnostics
    if results == nil then
      return diagnostics
    end
    for _, item in ipairs(results) do
      table.insert(diagnostics, {
        lnum = item.pos[1] - 1,
        col = item.pos[2] - 1,
        message = item.message,
        file = file_key,
        code = item.check_path,
        severity = vim.diagnostic.severity.INFO,
      })
    end
    return diagnostics
  end,
}
