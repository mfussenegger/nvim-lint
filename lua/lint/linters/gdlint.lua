local pattern = [[(%S+):(%d+):%s(%a+):%s(.*)]]
local groups = {
  'file',
  'lnum',
  'severity',
  'message',
}
local severity_map = {
  ['Error'] = vim.diagnostic.severity.WARN,
}

return {
  cmd = 'gdlint',
  stdin = false,
  append_fname = true,
  args = {},
  stream = 'stderr',
  ignore_exitcode = true,
  parser = require('lint.parser').from_pattern(
    pattern,
    groups,
    severity_map,
    { ['source'] = 'gdlint' }
  ),
}
