local M = {}

local DiagnosticSeverity = vim.lsp.protocol.DiagnosticSeverity

local severity_by_qftype = {
  E = DiagnosticSeverity.Error,
  W = DiagnosticSeverity.Warning,
  I = DiagnosticSeverity.Information,
  N = DiagnosticSeverity.Hint,
}

-- Return a parse function that uses an errorformat to parse the output.
-- See `:help errorformat`
function M.from_errorformat(efm, skeleton)
  return function(output)
    local lines = vim.split(output, '\n')
    local qflist = vim.fn.getqflist({ efm = efm, lines = lines })
    local result = {}
    local defaults = {
      severity = DiagnosticSeverity.Error,
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
          message = item.text:match('^%s*(.-)%s*$'),
          severity = severity_by_qftype[item.type]
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
      local start_col = tonumber(entries['start_col']) or 1
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
      ['error'] = DiagnosticSeverity.Error,
      ['warning'] = DiagnosticSeverity.Warning,
      ['information'] = DiagnosticSeverity.Information,
      ['hint'] = DiagnosticSeverity.Hint,
    }
  defaults = defaults or {}
  return function(output, bufnr)
    local diagnostics = {}
    local buffer_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")

    for _, line in ipairs(vim.fn.split(output, '\n')) do
      local results = { line:match(pattern) }
      local entries = {}

      -- Check that the regex matched
      if #results >= 3 then
        for i, match in ipairs(results) do
          entries[groups[i]] = match
        end

        -- Use the file group to filter diagnostics related to other files
        if not entries['file'] or vim.fn.fnamemodify(entries['file'], ":~:.") == buffer_path then
          local diagnostic = {}

          for key, handler in pairs(group_handler) do
            diagnostic[key] = handler(entries)
          end

          diagnostic = vim.tbl_deep_extend("force", defaults, diagnostic)
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
        local output = table.concat(chunks)
        local diagnostics = parse(output, bufnr)
        publish(diagnostics, bufnr)
      end)
    end,
  }
end


function M.split(parser)
  local remaining_calls = 2
  local chunks1 = {}
  local chunks2 = {}
  local function on_done(publish, bufnr)
    remaining_calls = remaining_calls - 1
    if remaining_calls == 0 then
      -- Ensure stdout/stderr output is not interleaved
      for _, chunk in pairs(chunks1) do
        parser.on_chunk(chunk)
      end
      for _, chunk in pairs(chunks2) do
        parser.on_chunk(chunk)
      end
      parser.on_done(publish, bufnr)
    end
  end
  local parser1 = {
    on_chunk = function(chunk)
      table.insert(chunks1, chunk)
    end,
    on_done = on_done,
  }
  local parser2 = {
    on_chunk = function(chunk)
      table.insert(chunks2, chunk)
    end,
    on_done = on_done,
  }
  return parser1, parser2
end


return M
