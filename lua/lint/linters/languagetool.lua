-- LanguageTool might give output like "Err: 'yada yada'\n{ ... json here ... }'
local function parse_err_json(str)
    local json_start = str:find('{', 1, true)
    local err = nil
    local json = str

    if json_start and json_start > 1 then
        err = str:sub(1, json_start - 1):gsub("^%s*(.-)%s*$", "%1") -- trim spaces
        json = str:sub(json_start)
    end

    return err, json
end

return {
  cmd = 'languagetool',
  args = {'--autoDetect', '--json'},
  stream = 'stdout',
  parser = function(output, bufnr)
    local err, json = parse_err_json(output)
    if err then
      vim.notify_once(err, vim.log.levels.INFO)
    end
    local decoded = vim.json.decode(json)
    local diagnostics = {}
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    local content = table.concat(lines, '\n')
    for _, match in pairs(decoded.matches or {}) do
      local byteidx = vim.fn.byteidx(content, match.offset)
      local line = vim.fn.byte2line(byteidx)
      local col = byteidx - vim.fn.line2byte(line)
      table.insert(diagnostics, {
        lnum = line - 1,
        end_lnum = line - 1,
        col = col + 1,
        end_col = col + 1,
        message = match.message,
      })
    end
    return diagnostics
  end,
}
