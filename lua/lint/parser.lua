local M = {}

-- Return a parse function that uses an errorformat to parse the output.
-- See `:help errorformat`
function M.from_errorformat(efm, skeleton)
  return function(output)
    local lines = vim.split(output, '\n')
    local qflist = vim.fn.getqflist({ efm = efm, lines = lines })
    local result = {}
    local defaults = {
      severity = vim.lsp.protocol.DiagnosticSeverity.Error,
    }
    for _, item in pairs(qflist.items) do
      if item.valid == 1 then
        local col = item.col > 0 and item.col - 1 or 0
        local position = { line = item.lnum - 1, character = col }
        local diagnostic = {
          range = {
            ['start'] = position,
            ['end'] = position,
          },
          message = item.text,
        }
        table.insert(result, vim.tbl_extend('keep', diagnostic, skeleton and skeleton or defaults))
      end
    end
    return result
  end
end

--- Parse a linter's output using a regex pattern
-- @param pattern The regex pattern
-- @param groups The groups defined by the pattern: {"line", "message", "start_col", ["end_col"], ["code"], ["code_desc"], ["file"], ["severity"]}
-- @param severity_map An optional table mapping the severity values to their codes
-- @param defaults An optional table of diagnostic default values
function M.from_pattern(pattern, groups, severity_map, defaults)
  local group_handler = {
    code = function(entries)
      return entries['code']
    end,

    codeDescription = function(entries)
      return entries['code_desc']
    end,

    message = function(entries)
      return entries['message']
    end,

    range = function(entries)
      local line = tonumber(entries['line'])
      local start_col = tonumber(entries['start_col'])
      local end_col = entries['end_col'] and tonumber(entries['end_col']) or start_col
      return {
        ['start'] = { line = line - 1, character = start_col - 1 },
        ['end'] = { line = line - 1, character = end_col },
      }
    end,

    severity = function(entries)
      return severity_map[entries['severity']] or defaults['severity'] or severity_map['error']
    end,
  }

  severity_map = severity_map
    or {
      ['error'] = vim.lsp.protocol.DiagnosticSeverity.Error,
      ['warning'] = vim.lsp.protocol.DiagnosticSeverity.Warning,
      ['information'] = vim.lsp.protocol.DiagnosticSeverity.Information,
      ['hint'] = vim.lsp.protocol.DiagnosticSeverity.Hint,
    }
  defaults = defaults or {}
  return function(output, bufnr)
    local diagnostics = {}
    local buffer_path = vim.api.nvim_buf_get_name(bufnr)

    for _, line in ipairs(vim.fn.split(output, '\n')) do
      local results = { line:gmatch(pattern)() }
      local entries = {}

      -- Check that the regex matched
      if #results >= 3 then
        for i, match in ipairs(results) do
          entries[groups[i]] = match
        end

        -- Use the file group to filter diagnostics related to other files
        if not entries['file'] or entries['file'] == buffer_path then
          local diagnostic = {}

          for key, handler in pairs(group_handler) do
            diagnostic[key] = handler(entries) or defaults[key]
          end
          table.insert(diagnostics, diagnostic)
        end
      end
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
