describe('linter.dmypy', function()
  it('can parse the output', function()
    local parser = require('lint.linters.dmypy').parser
    local bufnr = vim.uri_to_bufnr('file:///foo.py')
    local output = [[
/foo.py:10:15:10:20: error: Incompatible return value type (got "str", expected "bool") [return-value]
/foo.py:20:25:20:30: error: Argument 1 to "foo" has incompatible type "str"; expected "int" [arg-type]
]]
    local result = parser(output, bufnr)

    assert.are.same(2, #result)

    local expected_error = {
      source = 'dmypy',
      message = 'Incompatible return value type (got "str", expected "bool")',
      code = 'return-value',
      lnum = 9,
      col = 14,
      end_lnum = 9,
      end_col = 20,
      severity = vim.diagnostic.severity.ERROR,
      user_data = {
        lsp = {
          code = 'return-value'
        }
      }
    }
    assert.are.same(expected_error, result[1])

    local expected_warning = {
      source = 'dmypy',
      message = 'Argument 1 to "foo" has incompatible type "str"; expected "int"',
      code = 'arg-type',
      lnum = 19,
      col = 24,
      end_lnum = 19,
      end_col = 30,
      severity = vim.diagnostic.severity.ERROR,
      user_data = {
        lsp = {
          code = 'arg-type'
        }
      }
    }
    assert.are.same(expected_warning, result[2])
  end)
end)
