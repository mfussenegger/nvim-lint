describe('linter.pydocstyle', function()
  it("doesn't error on empty output", function()
    local parser = require('lint.linters.pydocstyle').parser
    parser('')
    parser('  ')
  end)

  it('can parse the output', function()
    local parser = require('lint.linters.pydocstyle').parser
    local result = parser([[
test.py:10 in public class `Foo`:
        D200: One-line docstring should fit on one line with quotes (found 3)
test.py:20 in public class `Bar`:
        D208: Docstring is over-indented
]]
    )
    assert.are.same(2, #result)

    local expected_error = {
      source = 'pydocstyle',
      message = 'One-line docstring should fit on one line with quotes (found 3)',
      lnum = 9,
      col = 0,
      end_lnum = 9,
      end_col = 0,
      severity = vim.diagnostic.severity.HINT,
    }
    assert.are.same(expected_error, result[1])

    local expected_warning = {
      source = 'pydocstyle',
      message = 'Docstring is over-indented',
      lnum = 19,
      col = 0,
      end_lnum = 19,
      end_col = 0,
      severity = vim.diagnostic.severity.HINT,
    }
    assert.are.same(expected_warning, result[2])
  end)
end)
