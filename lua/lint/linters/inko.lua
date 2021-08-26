local util = require('lint.util')

local severities = {
  error = vim.lsp.protocol.DiagnosticSeverity.Error,
  warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
}

-- Inko unit tests require the inclusion of an extra directory, otherwise we
-- won't be able to find some of the files imported into unit tests.
local function include_tests()
  local path = vim.fn.expand('%:p')
  local separator = vim.fn.has('win32') == 1 and '\\' or '/'
  local find = 'tests' .. separator .. 'test' .. separator

  if not path:match(find) then
    return
  end

  local tests_dir = util.find_nearest_directory('tests')

  return '--include=' .. tests_dir
end

return {
  cmd = 'inko',
  args = {
    'build',
    include_tests,
    '--format=json',
    '--check',
  },
  stream = 'stderr',
  stdin = false,
  ignore_exitcode = true,
  parser = function(output, _)
    local items = {}

    if output == '' then
      return items
    end

    local decoded = vim.fn.json_decode(output) or {}
    local bufpath = vim.fn.expand('%:p')

    for _, diag in ipairs(decoded) do
      if diag.file == bufpath then
        table.insert(items, {
          source = 'inko',
          range = {
            ['start'] = {
              line = diag.line - 1,
              character = diag.column - 1
            },
            ['end'] = {
              line = diag.line - 1,
              character = diag.column,
            },
          },
          message = diag.message,
          severity = assert(
            severities[diag.level],
            'missing mapping for severity ' .. diag.level
          )
        })
      end
    end

    return items
  end
}
