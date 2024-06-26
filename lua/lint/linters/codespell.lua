--- Sanitizes a string by escaping special Lua pattern characters.
-- This function replaces special characters used in Lua patterns with their escaped counterparts.
---@param str (string) The input string to be sanitized.
---@return (string) The sanitized string with escaped pattern characters.
local function sanitize(str)
  local rep_tbl = {
    ["%"] = "%%",
    ["-"] = "%-",
    ["+"] = "%+",
    ["*"] = "%*",
    ["?"] = "%?",
    ["^"] = "%^",
    ["$"] = "%$",
    ["."] = "%.",
    ["("] = "%(",
    [")"] = "%)",
    ["["] = "%[",
    ["]"] = "%]",
  }

  for what, with in pairs(rep_tbl) do
    what = string.gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
    with = string.gsub(with, "[%%]", "%%%%")                       -- escape replacement
    str = string.gsub(str, what, with)
  end

  return str
end

return {
  cmd = 'codespell',
  args = { "-" },
  stdin = true,
  ignore_exitcode = true,
  parser = function(output, bufnr, cwd)
    if output == '' then
      return {}
    end

    local pat_diag = "(%d+): - [^\n]+\n\t((%S+)[^\n]+)"
    local info = {}

    for row, message, misspelled in output:gmatch(pat_diag) do
      row = tonumber(row)
      if misspelled ~= nil then
        local lines = vim.api.nvim_buf_get_lines(bufnr, row >= 1 and row - 1 or 0, row, false)
        if #lines == 1 then
          misspelled = sanitize(misspelled)
          local line = lines[1]
          local col, end_col = line:find(misspelled)

          if col == nil then
            col = 0
          end

          if end_col == nil then
            end_col = 0
          end

          table.insert(info, {
            lnum = row >= 1 and row - 1 or 0,
            row = row,
            col = col >= 1 and col - 1 or 0,
            enl_lnum = row,
            end_col = end_col,
            source = "codespell",
            message = message,
            severity = vim.diagnostic.severity.INFO,
          })
        end
      end
    end

    return info
  end
}
