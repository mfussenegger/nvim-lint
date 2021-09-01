describe('linter.pycodestyle', function()
  it('can parse the output', function()
    local parser = require('lint.linters.pycodestyle').parser
    local result = parser([[
    test.py:26:1:E302:expected 2 blank lines, found 1
    test.py:37:80:E501:line too long (88 > 79 characters)
    test.py:69:48:W291:trailing whitespace
    test.py:411:13:E128:continuation line under-indented for visual indent
    ]])
    assert.are.same(4, #result)
    local expected = {
      source = 'pycodestyle',
      code = 'E302',
      message = 'expected 2 blank lines, found 1',
      range = {
        ['start'] = {
          character = 0,
          line = 25
        },
        ['end'] = {
          character = 1,
          line = 25
        },
      },
      severity = vim.lsp.protocol.DiagnosticSeverity.Warning,
    }
    assert.are.same(expected, result[1])
    local expected = {
      source = 'pycodestyle',
      code = 'W291',
      message = 'trailing whitespace',
      range = {
        ['start'] = {
          character = 47,
          line = 68
        },
        ['end'] = {
          character = 48,
          line = 68
        },
      },
      severity = vim.lsp.protocol.DiagnosticSeverity.Warning,
    }
    assert.are.same(expected, result[3])
  end)
end)
