local pattern = [[([^:]*):(%d+):(%d+): (%w+): ([^[]+)]]
local groups = { 'file', 'line', 'start_col', 'severity', 'message' }

return {
  cmd = 'clang-tidy',
  stdin = false,
  args = { '--quiet' },
  parser = require('lint.parser').from_pattern(pattern, groups, nil, { ['source'] = 'clang-tidy' }),
}
