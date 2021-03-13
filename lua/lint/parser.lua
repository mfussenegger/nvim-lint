
local M = {}


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
