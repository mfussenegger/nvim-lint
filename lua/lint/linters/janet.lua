-- janet prints errors with an `error: ` prefix:
--   error: path/to/file:line:col: message
-- but warnings from `--lint-warn` without it:
--   path/to/file:line:col: message
local function match_line(line)
  local lnum, col, message = line:match('^error: [^:]+:(%d+):(%d+):%s*(.+)$')
  if lnum then
    return { 'error', lnum, col, message }
  end
  lnum, col, message = line:match('^[^:]+:(%d+):(%d+):%s*(.+)$')
  if lnum then
    return { 'warning', lnum, col, message }
  end
  return {}
end

local groups = { 'severity', 'lnum', 'col', 'message' }

local severity_map = {
  ['warning'] = vim.diagnostic.severity.WARN,
  ['error'] = vim.diagnostic.severity.ERROR,
}

return {
  cmd = 'janet',
  stdin = true,
  args = {
    '-k',
  },
  stream = 'stderr',
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(match_line, groups, severity_map, {
    ['source'] = 'janet',
    ['severity'] = vim.diagnostic.severity.ERROR,
  }),
}
