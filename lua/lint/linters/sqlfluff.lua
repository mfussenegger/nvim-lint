-- this is a multi-line parser
-- example:
--[[
L:  53 | P:   1 | L013 | Column expression without alias. Use explicit `AS`
                       | clause.
]] --
local sqlfluff_pattern = 'L:([^|]+) | P:([^|]+) | ([^|]+) | (.*)'

return {
  cmd = "sqlfluff",
  args = {
    "lint",
    -- note: users will have to replace the --dialect argument accordingly
    "--dialect=postgresql", "-",
  },
  ignore_exitcode = true,
  stdin = true,
  parser = function(output, _)
    -- the way this parser works is:
    -- - extract a "report line which may have continuation"
    -- - go over each of those reports and add any continuations that they may have

    -- line_number_in_output → diagnostic info (partial message)
    local partial_diagnostic_per_output_line = {}

    local output_lines = vim.split(output, '\n')
    for output_i_line, output_line in ipairs(output_lines) do
      local line_nr, col_nr, error_code, partial_message = output_line:match(
                                                             sqlfluff_pattern)
      if line_nr then
        partial_diagnostic_per_output_line[output_i_line] = {
          source = 'sqlfluff',
          lnum = assert(tonumber(line_nr)) - 1,
          col = assert(tonumber(col_nr)) - 1,
          severity = vim.diagnostic.severity.ERROR,
          message = vim.trim(error_code) .. ": " .. vim.trim(partial_message),
        }
      end
    end

    -- we've got the reports
    -- now, we collect the rest of each messages directly into the diagnostics

    local diagnostics = {}
    local total_output_lines = vim.tbl_count(output_lines)
    for output_i_line, d in pairs(partial_diagnostic_per_output_line) do
      for _, output_line_i in ipairs(vim.fn.range(output_i_line + 1,
                                                  total_output_lines)) do
        if partial_diagnostic_per_output_line[output_line_i] ~= nil then
          break
        end
        local this_output_line = vim.trim(output_lines[output_line_i])
        -- if looking at end of output, just discard
        if this_output_line:match("^All Finished") then
          -- we've reached the end of the outputs
          break
        end
        -- ouput_i_line points to a line with the continuation of a message
        d.message = d.message .. " " ..
                      vim.trim(string.gsub(this_output_line, "^%s*[|]", ""))
      end
      vim.list_extend(diagnostics, {vim.fn.copy(d)})
    end
    return diagnostics
  end,
}
