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
      range = {
        ['start'] = {
          line = 9,
          character = 0,
        },
        ['end'] = {
          line = 9,
          character = 0,
        },
      },
      severity = vim.lsp.protocol.DiagnosticSeverity.Hint,
    }
    assert.are.same(expected_error, result[1])

    local expected_warning = {
      source = 'pydocstyle',
      message = 'Docstring is over-indented',
      range = {
        ['start'] = {
          line = 19,
          character = 0,
        },
        ['end'] = {
          line = 19,
          character = 0,
        },
      },
      severity = vim.lsp.protocol.DiagnosticSeverity.Hint,
    }
    assert.are.same(expected_warning, result[2])
  end)
end)
