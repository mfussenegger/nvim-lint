-- path/to/file:line: message
local pattern = '([^:]+):(%d+): (.*)'
local groups = { 'file', 'lnum', 'message' }

return {
  cmd = 'vulture',
  stdin = false,
  args = {"--exclude='/**/docs/*.py,/**/build/*.py'", function()
    local git_root_or_err = vim.fn.system("git rev-parse --show-toplevel"):sub(1, -2)
    if vim.startswith(git_root_or_err, 'fatal') then
        return vim.fn.getcwd()
    else
        return git_root_or_err
    end
  end},
  ignore_exitcode = true,
  append_fname = false,
  parser = require('lint.parser').from_pattern(pattern, groups, nil, {
    ['source'] = 'vulture',
    ['severity'] = vim.diagnostic.severity.WARN,
  }),
}
