-- This is a linter for https://rpm.org/
local parsers = {
  -- errors
  require('lint.parser').from_pattern(
    [[(%w+): line (%d+): (.*)]],
    { 'severity', 'lnum', 'message' },
    nil,
    {
      severity = vim.diagnostic.severity.ERROR,
      source = 'rpmspec'
    }
  ),

  -- warnings
  require('lint.parser').from_pattern(
    [[(%w+): (.*) on line (%d+):]],
    { 'severity', 'message', 'lnum' },
    nil,
    {
      severity = vim.diagnostic.severity.WARN,
      source = 'rpmspec'
    }
  ),
}

-- Usage: rpmspec -P <file>
return {
  cmd = 'rpmspec',
  stdin = false,
  append_fname = true,
  args = { '-P' },
  stream = 'stderr',
  ignore_exitcode = true,
  parser = function(output, bufnr, linter_cwd)
    local diagnostics = {}
    for _, parser in ipairs(parsers) do
      local result = parser(output, bufnr, linter_cwd)
      vim.list_extend(diagnostics, result)
    end
    return diagnostics
  end,
}
