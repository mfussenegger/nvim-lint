describe('linter.checkpatch', function()
  it('can parse the output', function()
    local linter = require('lint.linters.checkpatch')
    if type(linter) == 'function' then
      linter = linter()
    end
    local parser = linter.parser
    local bufnr = vim.uri_to_bufnr('file:///foo.c')
    local test_output = [[
-:9: CHECK: Please don't use multiple blank lines
-:11: WARNING: Missing a blank line after declarations
-:13: ERROR: switch and case should be at the same indent
]]
    local result = parser(test_output, bufnr)

  assert.are.same(3, #result)

  local expected_info = {
    source = 'checkpatch',
    message = 'Please don\'t use multiple blank lines',
    lnum = 5,
    col = 0,
    end_lnum = 5,
    end_col = 0,
    severity = vim.diagnostic.severity.INFO,
  }
  assert.are.same(expected_info, result[1])

  local expected_warning = {
    source = 'checkpatch',
    message = 'Missing a blank line after declarations',
    lnum = 7,
    col = 0,
    end_lnum = 7,
    end_col = 0,
    severity = vim.diagnostic.severity.WARN,
  }
  assert.are.same(expected_warning, result[2])

  local expected_error = {
    source = 'checkpatch',
    message = 'switch and case should be at the same indent',
    lnum = 9,
    col = 0,
    end_lnum = 9,
    end_col = 0,
    severity = vim.diagnostic.severity.ERROR,
  }
  assert.are.same(expected_error, result[3])

  end)
end)
