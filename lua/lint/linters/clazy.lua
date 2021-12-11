-- Clazy will also emit clang's regular compiler warnings.
-- There doesn't seem to be a way to disable this,
-- so only filter out the ones starting with -Wclazy-
local pattern = [=[([^:]*):(%d+):(%d+): (%w+): ([^[]+) %[%-Wclazy%-(.*)%]]=]
local groups = { 'file', 'lnum', 'col', 'severity', 'message', 'code'}

return {
  cmd = 'clazy-standalone',
  stdin = false,
  args = {},
  stream = 'stderr',
  parser = require('lint.parser').from_pattern(pattern, groups, nil, { ['source'] = 'clazy' }),
}
