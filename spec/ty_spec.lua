describe('linter.ty', function()
  it('can parse the output', function()
    local parser = require('lint.linters.ty').parser
    local bufnr = vim.uri_to_bufnr('file:///tmp/test_ty.py')
    local output = [[
/tmp/test_ty.py:1:10: error[invalid-assignment] Object of type `Literal["string"]` is not assignable to `int`
/tmp/test_ty.py:5:5: warn[unused-variable] Variable `x` is never used
]]
    local result = parser(output, bufnr)

    assert.are.same(2, #result)

    local expected_error = {
      source = 'ty',
      message = 'Object of type `Literal["string"]` is not assignable to `int`',
      code = 'invalid-assignment',
      lnum = 0,
      col = 9,
      severity = vim.diagnostic.severity.ERROR,
      user_data = {
        lsp = {
          code = 'invalid-assignment'
        }
      }
    }
    assert.are.same(expected_error, result[1])

    local expected_warning = {
      source = 'ty',
      message = 'Variable `x` is never used',
      code = 'unused-variable',
      lnum = 4,
      col = 4,
      severity = vim.diagnostic.severity.WARN,
      user_data = {
        lsp = {
          code = 'unused-variable'
        }
      }
    }
    assert.are.same(expected_warning, result[2])
  end)
end)