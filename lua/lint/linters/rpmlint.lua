local severity = {
  ['W'] = vim.diagnostic.severity.WARN,
  ['E'] = vim.diagnostic.severity.ERROR,
}

local parsers = {
  require('lint.parser').from_pattern(
    'warning: line (%d+): (.*)',
    { 'lnum', 'message' },
    nil,
    {
      severity = vim.diagnostic.severity.WARN,
      source = 'rpmlint'
    }
  ),

  require('lint.parser').from_pattern(
    '.*:(%d+): ([W|E]): (.*)',
    { 'lnum', 'severity', 'message' },
    severity,
    {
      severity = vim.diagnostic.severity.WARN,
      source = 'rpmlint'
    }
  ),

  require('lint.parser').from_pattern(
    '.*: E: .*: line (%d+): (.*)',
    { 'lnum', 'message' },
    nil,
    {
      severity = vim.diagnostic.severity.ERROR,
      source = 'rpmlint'
    }
  ),

}

return {
  cmd = 'rpmlint',
  stdin = false,
  append_fname = true,
  args = {},
  stream = 'both',
  ignore_exitcode = true,
  parser = function(output, bufnr, cwd)
    local diagnostics = {}
    for _, parser in ipairs(parsers) do
      local result = parser(output, bufnr, cwd)
      vim.list_extend(diagnostics, result)
    end
    return diagnostics
  end,
}
