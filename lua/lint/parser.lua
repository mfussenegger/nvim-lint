---@mod lint.parser Parsers and parse functions
---
local M = {}
local vd = vim.diagnostic
local api = vim.api

local maxint = 2 ^ 32 - 1
M.maxint = maxint

local severity_by_qftype = {
  E = vd.severity.ERROR,
  W = vd.severity.WARN,
  I = vd.severity.INFO,
  N = vd.severity.HINT,
}

---Return a parse function that uses an errorformat to parse the output.
---@param efm string Format following |errorformat|
---@param skeleton table<string, any> | vim.Diagnostic default values
---@return lint.parse
function M.from_errorformat(efm, skeleton)
  skeleton = skeleton or {}
  skeleton.severity = skeleton.severity or vd.severity.ERROR
  return function(output, bufnr)
    local lines = vim.split(output, '\n')
    local qflist = vim.fn.getqflist({ efm = efm, lines = lines })
    local result = {}
    for _, item in ipairs(qflist.items) do
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


---Return a parse function that parses a linter's output using a Lua or LPEG pattern.
---
---@param pattern string|vim.lpeg.Pattern|fun(line: string):string[]
---@param groups string[]
---@param severity_map? table<string, vim.diagnostic.Severity>
---@param defaults? table
---@param opts? {col_offset?: integer, end_col_offset?: integer, lnum_offset?: integer, end_lnum_offset?: integer}
---@return lint.parse
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
      if (string.match(captures.file, '^%w:') or vim.startswith(captures.file, '/')) then
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
    local lnum = captures.lnum and tonumber(captures.lnum) - 1 or 0
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
    if not api.nvim_buf_is_valid(bufnr) then
      return {}
    end
    local result = {}
    local buffer_path = vim.fn.fnamemodify(api.nvim_buf_get_name(bufnr), ":p")
    --- bwc for 0.6 requires boolean arg instead of table
    ---@diagnostic disable-next-line: param-type-mismatch
    for line in vim.gsplit(output, "\n", true) do
      local diagnostic = match(linter_cwd, buffer_path, line)
      if diagnostic then
        table.insert(result, diagnostic)
      end
    end
    return result
  end
end


---Return a parse function for the Static Analysis Results Interchange Format (SARIF).
---https://sarifweb.azurewebsites.net/
---@param skeleton? table<string, any> | vim.Diagnostic default values
---@return lint.parse
function M.for_sarif(skeleton)
  skeleton = skeleton or {}
  skeleton.severity = skeleton.severity or vd.severity.ERROR

  local severities = {
    error = vd.severity.ERROR,
    warning = vd.severity.WARN,
    note = vd.severity.INFO,
  }

  ---@param output string the output of the tool
  ---@param bufnr number the number of the buffer the linter ran on
  ---@return vim.Diagnostic[] the diagnostics
  return function(output, bufnr)
    local diagnostics = {}
    local decoded = vim.json.decode(output) or {}
    for _, run in ipairs(decoded.runs or {}) do
      local tool = run.tool or {}
      local driver = tool.driver or {}
      local source = driver.name
      local rules = driver.rules or {}
      local id_rules = {}
      for _, rule in ipairs(rules) do
        id_rules[rule.id] = rule
      end
      for _, result in ipairs(run.results or {}) do
        for _, location in ipairs(result.locations) do
          local uri = location.physicalLocation.artifactLocation.uri
          local location_bufnr = vim.uri_to_bufnr(uri)
          if bufnr == location_bufnr then
            local region = location.physicalLocation.region

            local rule = result.ruleId and id_rules[result.ruleId]
            if not rule then
              rule = result.ruleIndex and rules[result.ruleIndex + 1] or {}
            end

            local severity = result.level
              and severities[result.level]
              or vim.tbl_get(rule, "properties", "priority")

            -- If endColumn is absent, it SHALL default to a value one greater
            -- than the column number of the last character on the line,
            -- excluding any newline sequence.
            local end_col = region.endColumn and region.endColumn - 2 or maxint
            table.insert(
              diagnostics,
              vim.tbl_extend("keep", {
                lnum = region.startLine - 1,
                end_lnum = region.endLine and region.endLine - 1,
                col = region.startColumn and region.startColumn - 1 or 0,
                end_col = end_col,
                severity = severity,
                message = result.message.text,
                source = source,
                code = result.ruleId,
              }, skeleton or {})
            )
          end
        end
      end
    end
    return diagnostics
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
---@return lint.Parser
function M.accumulate_chunks(parse)
  local chunks = {}
  return {
    on_chunk = function(chunk)
      table.insert(chunks, chunk)
    end,
    on_done = function(publish, bufnr, linter_cwd)
      vim.schedule(function()
        local output = table.concat(chunks)
        if api.nvim_buf_is_valid(bufnr) and output ~= "" then
          local ok, diagnostics
          if api.nvim_buf_call then
            api.nvim_buf_call(bufnr, function()
              ok, diagnostics = pcall(parse, output, bufnr, linter_cwd)
            end)
          else
            ok, diagnostics = pcall(parse, output, bufnr, linter_cwd)
          end
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


---Split a parser into two
---
---@param parser lint.Parser
---@return lint.Parser, lint.Parser
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
