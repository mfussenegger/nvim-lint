-- stdout output in the form "63: resourcs ==> resources, resource"
local api = vim.api
local pattern = "(%d+): (.*)"
local groups = { "lnum", "message" }
local severities = nil -- none provided
local parser = require('lint.parser').from_pattern(pattern, groups, severities, {
  source = 'codespell',
  severity = vim.diagnostic.severity.INFO,
})
return {
  cmd = 'codespell',
  args = { '--stdin-single-line', "-" },
  stdin = true,
  ignore_exitcode = true,
  parser = function(output, bufnr, cwd)
    local result = parser(output, bufnr, cwd)
    for _, d in ipairs(result) do
      local start, _, capture = d.message:find("(.*) ==>")
      if start then
        -- lenient - lint is async and buffer can change between lint start and result parsing
        local ok, lines = pcall(api.nvim_buf_get_lines, bufnr, d.lnum, d.lnum + 1, true)
        if ok then
          local line = lines[1] or ""
          local end_
          start, end_ = line:find(vim.pesc(capture))
          if start then
            d.col = start - 1
            d.end_col = end_
          end
        end
      end
    end
    return result
  end,
}
