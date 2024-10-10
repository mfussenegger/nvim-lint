describe('linter.mypy', function()
  it('can parse the output', function()
    local parser = require('lint.linters.mypy').parser
    local bufnr = vim.uri_to_bufnr('file:///foo.py')
    local output = [[
/foo.py:10:15:10:20: error: Incompatible return value type (got "str", expected "bool")
/foo.py:20:25:20:30: error: Argument 1 to "foo" has incompatible type "str"; expected "int"
]]
    local result = parser(output, bufnr)

    assert.are.same(2, #result)

    local expected_error = {
      source = 'mypy',
      message = 'Incompatible return value type (got "str", expected "bool")',
      lnum = 9,
      col = 14,
      end_lnum = 9,
      end_col = 20,
      severity = vim.diagnostic.severity.ERROR,
    }
    assert.are.same(expected_error, result[1])

    local expected_warning = {
      source = 'mypy',
      message = 'Argument 1 to "foo" has incompatible type "str"; expected "int"',
      lnum = 19,
      col = 24,
      end_lnum = 19,
      end_col = 30,
      severity = vim.diagnostic.severity.ERROR,
    }
    assert.are.same(expected_warning, result[2])
  end)
end)
