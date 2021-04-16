local M = {}


-- Return a parse function that uses a pattern to parse the output.
--
-- The first argument is a lua pattern.
-- The pattern must match 4 groups in order: line number, offset, code and message
--
-- The second argument is a skeleton, used to create each diagnostic.
-- It should contain default values - for example the `source` and `severity`.
--
-- The output of the linter must have 1 entry per line
function M.from_pattern(pattern, diagnostic_skeleton)
  return function(output)
    local result = vim.fn.split(output, "\n")
    local diagnostics = {}

    for _, message in ipairs(result) do
      local lineno, offset, code, msg = string.match(message, pattern)
      lineno = tonumber(lineno or 1) - 1
      offset = tonumber(offset or 1) - 1
      local d = vim.deepcopy(diagnostic_skeleton)
      table.insert(diagnostics, vim.tbl_deep_extend('force', d, {
        code = code,
        range = {
          ['start'] = {line = lineno, character = offset},
          ['end'] = {line = lineno, character = offset + 1}
        },
        message = code .. ' ' .. msg,
      }))
    end
    return diagnostics
  end
end


function M.accumulate_chunks(parse)
  local chunks = {}
  return {
    on_chunk = function(chunk)
      table.insert(chunks, chunk)
    end,
    on_done = function(publish, bufnr)
      vim.schedule(function()
        local ok, diagnostics = pcall(parse, table.concat(chunks), bufnr)
        assert(ok, diagnostics)
        publish(diagnostics)
      end)
    end,
  }
end

return M
