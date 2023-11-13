-- stdout output in the form "163: // adn print test\n\tadn ==> and"
local linter_pattern = "(%d+):.*\n\t(.*)"
local linter_groups = { "lnum", "message" }
local linter_severities = nil -- none provided

-- custom parser which concatenates two consecutive lines before parsing
-- changes compared to standard parser in lines 68..76
local function from_pattern(pattern, groups, severity_map, defaults, opts)
  defaults = defaults or {}
  severity_map = severity_map or {}
  opts = opts or {}
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
    local lnum_offset = opts.lnum_offset or 0
    local end_lnum_offset = opts.end_lnum_offset or 0
    local col_offset = opts.col_offset or -1
    local end_col_offset = opts.end_col_offset or -1
    local lnum = tonumber(captures.lnum) - 1
    local end_lnum = captures.end_lnum and (tonumber(captures.end_lnum) - 1) or lnum
    local col = tonumber(captures.col) and (tonumber(captures.col) + col_offset) or 0
    local end_col = tonumber(captures.end_col) and (tonumber(captures.end_col) + end_col_offset) or col
    local diagnostic = {
      lnum = assert(lnum, 'diagnostic requires a line number') + lnum_offset,
      end_lnum = end_lnum + end_lnum_offset,
      col = assert(col, 'diagnostic requires a column number'),
      end_col = end_col,
      severity = severity_map[captures.severity] or defaults.severity or vim.diagnostic.severity.ERROR,
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
    local split_output = vim.fn.split(output, '\n')
    for idx, line in ipairs(split_output) do
      if idx % 2 == 0 then goto continue end
      line = table.concat({line, split_output[idx+1]}, "\n")
      local diagnostic = match(linter_cwd, buffer_path, line)
      if diagnostic then
        table.insert(result, diagnostic)
      end
      ::continue::
    end
    return result
  end
end
return {
  cmd = 'codespell',
  args = { '-' },
  stdin = true,
  ignore_exitcode = true,
  parser = from_pattern(linter_pattern, linter_groups, linter_severities, {
    source = 'codespell',
    severity = vim.diagnostic.severity.INFO,
  }),
}
