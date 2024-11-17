describe('linter.sphinx-lint', function()
  it('can parse the output', function()
    local parser = require('lint.linters.sphinx-lint').parser
    local bufnr = vim.uri_to_bufnr('file:///foo.rst')
    local result = parser([[
/foo.rst:42: trailing whitespace (trailing-whitespace)
/foo.rst:420: missing space before default role: beep boop (missing-space-before-default-role)
]], bufnr)

  assert.are.same(2, #result)

  local expected_error = {
    source = 'sphinx-lint',
    message = 'trailing whitespace (trailing-whitespace)',
    lnum = 41,
    col = 0,
    end_lnum = 41,
    end_col = 0,
    severity = vim.diagnostic.severity.WARN,
  }
  assert.are.same(expected_error, result[1])

  expected_error = {
    source = 'sphinx-lint',
    message = 'missing space before default role: beep boop (missing-space-before-default-role)',
    lnum = 419,
    col = 0,
    end_lnum = 419,
    end_col = 0,
    severity = vim.diagnostic.severity.WARN,
  }
  assert.are.same(expected_error, result[2])

  end)
end)
