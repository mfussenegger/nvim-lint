return {
  cmd = 'csharpier',
  -- `csharpier check` with stdin behaves like `format` and always exits 0,
  -- so the file on disk is checked instead (requires csharpier >= 1.0)
  stdin = false,
  append_fname = true,
  args = { 'check', '--no-msbuild-check' },
  stream = 'stderr',
  ignore_exitcode = true,
  parser = function(output)
    if not output:find('Was not formatted', 1, true) then
      return {}
    end
    local lnum = tonumber(output:match('Expected: Around Line (%d+)')) or 1
    local message = 'File is not formatted'
    local expected = output:match('%-%-%-+ Expected: Around Line %d+ %-%-%-+\n(.-)\n%s*%-%-%-+ Actual:')
    if expected then
      -- csharpier indents the snippet by two spaces for display; strip it
      expected = expected:gsub('^  ', ''):gsub('\n  ', '\n'):gsub('%s+$', '')
      message = 'Replace by:\n' .. expected
    end
    return {
      {
        lnum = lnum - 1,
        col = 0,
        severity = vim.diagnostic.severity.WARN,
        source = 'csharpier',
        message = message,
      },
    }
  end,
}
