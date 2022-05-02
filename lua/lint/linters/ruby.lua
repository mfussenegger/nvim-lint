local pattern1 = '([^:]+):(%d+): warning: (.+)'
local groups1 = { 'file', 'lnum', 'message' }

local pattern2 = '([^:]+):(%d+): syntax error, (.+)'
local groups2 = { 'file', 'lnum', 'message' }

local parsers = {
  require('lint.parser').from_pattern(
    pattern1,
    groups1,
    nil,
    { ['severity'] = vim.diagnostic.severity.WARN, ['source'] = 'ruby' }
  ),
  require('lint.parser').from_pattern(
    pattern2,
    groups2,
    nil,
    { ['severity'] = vim.diagnostic.severity.ERROR, ['source'] = 'ruby' }
  ),
}

return {
  cmd = 'ruby',
  stdin = false,
  args = { '-w', '-c' },
  ignore_exitcode = true,
  stream = 'stderr',
  parser = function(output, bufnr)
    local diagnostics = {}
    for _, parser in ipairs(parsers) do
      local result = parser(output, bufnr)
      for _, diagnostic in ipairs(result) do
        table.insert(diagnostics, diagnostic)
      end
    end

    return diagnostics
  end,
}
