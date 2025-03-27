local pattern = '^::(%a+) file=([^,]+),line=(%d+),col=(%d+)::(.+):%d+:%d+ %-%- (.+)'
local groups = { 'severity', 'file', 'lnum', 'col', 'code', 'message' }
local severity_map = {
  ['error'] = vim.diagnostic.severity.ERROR,
}

local bin = 'twig-cs-fixer'
return {
  cmd = function ()
    local local_bin = vim.fn.fnamemodify('vendor/bin/' .. bin, ':p')
    return vim.loop.fs_stat(local_bin) and local_bin or bin
  end,
  stdin = false,
  args = {
    'lint',
    '--report',
    'github',
    '--debug',
  },
  stream = 'stdout',
  ignore_exitcode = true,
  parser = require("lint.parser").from_pattern(pattern, groups, severity_map, { ["source"] = "twig-cs-fixer" }),
}
