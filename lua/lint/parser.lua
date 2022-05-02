local M = {}
local vd = vim.diagnostic

local severity_by_qftype = {
  E = vd.severity.ERROR,
  W = vd.severity.WARN,
  I = vd.severity.INFO,
  N = vd.severity.HINT,
}

-- Return a parse function that uses an errorformat to parse the output.
-- See `:help errorformat`
function M.from_errorformat(efm, skeleton)
  skeleton = skeleton or {}
  skeleton.severity = skeleton.severity or vd.severity.ERROR
  return function(output)
    local lines = vim.split(output, '\n')
    local qflist = vim.fn.getqflist({ efm = efm, lines = lines })
    local result = {}
    for _, item in pairs(qflist.items) do
      if item.valid == 1 then
        local lnum = math.max(0, item.lnum - 1)
        local col = math.max(0, item.col - 1)
        local end_lnum = item.end_lnum > 0 and (item.end_lnum - 1) or lnum
        local end_col = item.end_col > 0 and (item.end_col - 1) or col
        local severity = item.type ~= "" and severity_by_qftype[item.type:upper()] or nil
        local diagnostic = {
          lnum = lnum,
          col = col,
          end_lnum = end_lnum,
          end_col = end_col,
          severity = severity,
          message = item.text:match('^%s*(.-)%s*$'),
        }
        table.insert(result, vim.tbl_extend('keep', diagnostic, skeleton or {}))
      end
    end
    return result
  end
end

--- Parse a linter's output using a Lua pattern
--
function M.from_pattern(pattern, groups, severity_map, defaults)
  defaults = defaults or {}
  severity_map = severity_map or {}
  -- Like vim.diagnostic.match but also checks if a `file` group matches the buffer path
  -- Some linters produce diagnostics for the full project and this should only produce buffer diagnostics
  local match = function(linter_cwd, buffer_path, line)
    local matches = { line:match(pattern) }
    if not next(matches) then
      return nil
    end
    local captures = {}
    for i, match in ipairs(matches) do
      captures[groups[i]] = match
    end
    if captures.file then
      local path
      if vim.startswith(captures.file, '/') then
        path = captures.file
      else
        path = vim.fn.simplify(linter_cwd .. '/' .. captures.file)
      end
      if path ~= buffer_path then
        return nil
      end
    end
    local lnum = tonumber(captures.lnum) - 1
    local end_lnum = captures.end_lnum and (tonumber(captures.end_lnum) - 1) or lnum
    local col = tonumber(captures.col) and tonumber(captures.col) - 1 or 0
    local end_col = tonumber(captures.end_col) and tonumber(captures.end_col) - 1 or col
    local diagnostic = {
      lnum = assert(lnum, 'diagnostic requires a line number'),
      end_lnum = end_lnum,
      col = assert(col, 'diagnostic requires a column number'),
      end_col = end_col,
      severity = severity_map[captures.severity] or defaults.severity or vd.severity.ERROR,
      message = assert(captures.message, 'diagnostic requires a message'),
      code = captures.code
    }
    if captures.code or captures.code_desc then
      diagnostic.user_data = {
        lsp = {
          code = captures.code,
          codeDescription = captures.code_desc,
        }
      }
    end
    return vim.tbl_extend('keep', diagnostic, defaults or {})
  end
  return function(output, bufnr, linter_cwd)
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return {}
    end
    local result = {}
    local buffer_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")
    for _, line in ipairs(vim.fn.split(output, '\n')) do
      local diagnostic = match(linter_cwd, buffer_path, line)
      if diagnostic then
        table.insert(result, diagnostic)
      end
    end
    return result
  end
end


function M.accumulate_chunks(parse)
  local chunks = {}
  return {
    on_chunk = function(chunk)
      table.insert(chunks, chunk)
    end,
    on_done = function(publish, bufnr, linter_cwd)
      vim.schedule(function()
        local output = table.concat(chunks)
        local diagnostics
        if vim.api.nvim_buf_is_valid(bufnr) then
          diagnostics = parse(output, bufnr, linter_cwd)
        else
          diagnostics = {}
        end
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
