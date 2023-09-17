-- https://github.com/crate-ci/typos
return {
  cmd = "typos",
  stdin = true,
  append_fname = true,
  args = { "--format", "json", "-" },
  stream = "stdout",
  ignore_exitcode = true,
  env = nil,
  --
  ---@param output string
  ---@param _ number
  ---@return table
  parser = function(output, _)
    local diagnostics = {}

    if output == "" then
      return {}
    end

    -- Each line contains an entry of JSON. E.g.:
    --   {"type":"binary_file","path":"./lua/init_rs.so"}
    --   {"type":"typo","path":"./lua/plugins/23_package-info-nvim.lua","line_num":15,"byte_offset":37,"typo":"nd","corrections":["and"]}
    --   {"type":"binary_file","path":"./spell/en.utf-8.add.spl"}
    for json in string.gmatch(output, "[%S]+") do
      local item = vim.json.decode(json)

      if item ~= nil then
        local line_num = item.line_num - 1
        local corrections = table.concat(item.corrections, " or ")

        table.insert(diagnostics, {
          lnum = line_num,
          end_lnum = line_num,
          col = item.byte_offset,
          end_col = item.byte_offset + item.type:len(),
          severity = vim.diagnostic.severity.WARN,
          source = "[typos] " .. item.type,
          message = "`" .. item.typo .. "` should be `" .. corrections .. "`",
        })
      end
    end

    return diagnostics
  end,
}
