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
---@param efm string
---@param skeleton table<string, any> | vim.Diagnostic
---@return fun(output: string, bufnr: integer):lsp.Diagnostic[]
function M.from_errorformat(efm, skeleton)
  skeleton = skeleton or {}
  skeleton.severity = skeleton.severity or vd.severity.ERROR
  return function(output, bufnr)
    local lines = vim.split(output, '\n')
    local qflist = vim.fn.getqflist({ efm = efm, lines = lines })
    local result = {}
    for _, item in pairs(qflist.items) do
      if item.valid == 1 and (bufnr == nil or item.bufnr == 0 or item.bufnr == bufnr) then
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

local normalize = (vim.fs ~= nil and vim.fs.normalize ~= nil)
  and vim.fs.normalize
  or function(path) return path end


--- Parse a linter's output using a Lua pattern
---
---@param pattern string|vim.lpeg.Pattern|fun(line: string):string[]
---@param groups string[]
---@param severity_map? table<string, vim.diagnostic.Severity>
---@param defaults? table
---@param opts? {col_offset?: integer, end_col_offset?: integer, lnum_offset?: integer, end_lnum_offset?: integer}
---@return fun(output: string, bufnr: integer, cwd: string):lsp.Diagnostic[]
function M.from_pattern(pattern, groups, severity_map, defaults, opts)
  defaults = defaults or {}
  severity_map = severity_map or {}
  opts = opts or {}

  local type_ = type(pattern)
  local matchline
  if type_ == "string" then
    matchline = function(line)
      return { line:match(pattern) }
    end
  elseif type_ == "function" then
    matchline = pattern
  else
    matchline = function(line)
      return { pattern:match(line) }
    end
  end


  -- Like vim.diagnostic.match but also checks if a `file` group matches the buffer path
  -- Some linters produce diagnostics for the full project and this should only produce buffer diagnostics
  local match = function(linter_cwd, buffer_path, line)
    local ok, matches = pcall(matchline, line)
    if not ok then
      error(string.format("pattern match failed on line: %s with error: %q", line, matches))
    end
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
      if normalize(path) ~= normalize(buffer_path) then
        return nil
      end
    end
    local lnum_offset = opts.lnum_offset or 0
    local end_lnum_offset = opts.end_lnum_offset or 0
    local col_offset = opts.col_offset or -1
    local end_col_offset = opts.end_col_offset or -1
    local lnum = tonumber(captures.lnum) - 1
    local end_lnum = captures.end_lnum and (tonumber(captures.end_lnum) - 1) or lnum
    local col = tonumber(captures.col) and (tonumber(captures.col) + col_offset) or 0
    local end_col = tonumber(captures.end_col) and (tonumber(captures.end_col) + end_col_offset) or col
    col = math.max(col, 0)
    lnum = math.max(lnum, 0)
    local diagnostic = {
      lnum = assert(lnum, 'diagnostic requires a line number') + lnum_offset,
      end_lnum = end_lnum + end_lnum_offset,
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


local parse_failure_msg = [[Parser failed. Error message:
%s

Output from linter:
%s
]]


--- Turn a parse function into a parser table
---
---@param parse fun(output: string, bufnr: integer, cwd: string):vim.Diagnostic[]
---@return {on_chunk: fun(chunk: string), on_done: fun(publish: fun(diagnostics: vim.Diagnostic[], bufnr: integer), bufnr: integer, cwd: string)}
function M.accumulate_chunks(parse)
  local chunks = {}
  return {
    on_chunk = function(chunk)
      table.insert(chunks, chunk)
    end,
    on_done = function(publish, bufnr, linter_cwd)
      vim.schedule(function()
        local output = table.concat(chunks)
        if vim.api.nvim_buf_is_valid(bufnr) and output ~= "" then
          local ok, diagnostics = pcall(parse, output, bufnr, linter_cwd)
          if not ok then
            local err = diagnostics
            diagnostics = {
              {
                bufnr = bufnr,
                lnum = 0,
                col = 0,
                message = string.format(parse_failure_msg, err, output),
                severity = vim.diagnostic.severity.ERROR
              }
            }
          end
          publish(diagnostics, bufnr)
        else
          publish({}, bufnr)
        end
      end)
    end,
  }
end


function M.split(parser)
  local remaining_calls = 2
  local chunks1 = {}
  local chunks2 = {}
  local function on_done(publish, bufnr, cwd)
    remaining_calls = remaining_calls - 1
    if remaining_calls == 0 then
      -- Ensure stdout/stderr output is not interleaved
      for _, chunk in pairs(chunks1) do
        parser.on_chunk(chunk)
      end
      for _, chunk in pairs(chunks2) do
        parser.on_chunk(chunk)
      end
      parser.on_done(publish, bufnr, cwd)
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
