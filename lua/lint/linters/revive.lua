-- path/to/file:line:col: code message
local pattern = '[^:]+:(%d+):(%d+): (.*)'
local groups = { 'lnum', 'col', 'message' }

return {
  cmd = 'revive',
  stdin = false,
  args = {},
  parser = require('lint.parser').from_pattern(pattern, groups, nil, {
    ['source'] = 'revive',
  }),
}
