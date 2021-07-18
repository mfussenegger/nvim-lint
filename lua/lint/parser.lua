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
-- @param groups The groups defined by the pattern: {"lineno", "message", ("colno" | "colbeg", "colend"), ["code"], ["codeDesc"], ["file"], ["severity"]}
-- @param severity_map An optional table mapping the severity values to their codes
-- @param defaults An optional table of diagnostic default values
function M.from_pattern(pattern, groups, severity_map, defaults)
  local group_handler = {
    code = function(entries)
      return entries['code']
    end,

    codeDescription = function(entries)
      return entries['codeDesc']
    end,

    data = function(_)
      return nil -- Unsupported
    end,

    message = function(entries)
      return entries['message']
    end,

    range = function(entries)
      local lineno = tonumber(entries['lineno'])
      if entries['colbeg'] ~= nil and entries['colend'] ~= nil then
        local colbeg, colend = tonumber(entries['colbeg']), tonumber(entries['colend'])
        return {
          ['start'] = { line = lineno - 1, character = colbeg - 1 },
          ['end'] = { line = lineno - 1, character = colend },
        }
      end

      local colno = entries['colno'] ~= nil and tonumber(entries['colno']) or 1
      return {
        ['start'] = { line = lineno - 1, character = colno - 1 },
        ['end'] = { line = lineno - 1, character = colno },
      }
    end,

    relatedInformation = function(_)
      return nil -- Unsupported
    end,

    severity = function(entries)
      return severity_map[entries['severity']] or severity_map['error']
    end,

    source = function(_)
      return nil -- Unsupported
    end,

    tags = function(_)
      return nil -- Unsupported
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
  return function(output)
    local diagnostics = {}
    for _, line in ipairs(vim.fn.split(output, '\n')) do
      local results = { line:gmatch(pattern)() }
      local entries = {}

      -- Check that the regex matched
      if #results >= 3 then
        for i, match in ipairs(results) do
          entries[groups[i]] = match
        end

        local diagnostic = {}

        for key, handler in pairs(group_handler) do
          diagnostic[key] = handler(entries) or defaults[key]
        end
        table.insert(diagnostics, diagnostic)
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
