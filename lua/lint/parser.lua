
local M = {}


function M.accumulate_chunks(parse)
  local chunks = {}
  return {
    on_chunk = function(_, chunk)
      table.insert(chunks, chunk)
    end,
    on_done = function(bufnr, publish)
      vim.schedule(function()
        local ok, diagnostics = pcall(parse, bufnr, table.concat(chunks))
        assert(ok, diagnostics)
        publish(diagnostics)
      end)
    end,
  }
end

return M
