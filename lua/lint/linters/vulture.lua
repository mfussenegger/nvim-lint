-- path/to/file:line: message
local pattern = '([^:]+):(%d+): (.*)'
local groups = { 'file', 'lnum', 'message' }

return {
  cmd = 'vulture',
  stdin = false,
  args = {"--exclude='/**/docs/*.py,/**/build/*.py'", function()
    local output = vim.fn.system("git rev-parse --show-toplevel"):sub(1, -2)
    if output:match("^([%w]+)") == "fatal" then
        -- Return the current dir
        return vim.fn.getcwd()
    else
        -- Return the path to git root directory
        return output
    end
  end},
  ignore_exitcode = true,
  append_fname = false,
  parser = require('lint.parser').from_pattern(pattern, groups, nil, {
    ['source'] = 'vulture',
    ['severity'] = vim.diagnostic.severity.WARN,
  }),
}
