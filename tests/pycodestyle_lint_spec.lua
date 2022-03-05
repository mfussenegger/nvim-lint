describe('linter.pycodestyle', function()
  it("doesn't error on empty output", function()
    local parser = require('lint.linters.pycodestyle').parser
    parser('', vim.api.nvim_get_current_buf())
    parser('  ', vim.api.nvim_get_current_buf())
  end)

  it('can parse the output', function()
    local parser = require('lint.linters.pycodestyle').parser
    local result = parser([[
    test.py:26:1:E302:expected 2 blank lines, found 1
    test.py:37:80:E501:line too long (88 > 79 characters)
    test.py:69:48:W291:trailing whitespace
    test.py:411:13:E128:continuation line under-indented for visual indent
    ]], vim.api.nvim_get_current_buf())
    assert.are.same(4, #result)
    local expected_error = {
      code = 'E302',
      source = 'pycodestyle',
      message = 'expected 2 blank lines, found 1',
      lnum = 25,
      col = 0,
      end_lnum = 25,
      end_col = 0,
      severity = vim.diagnostic.severity.WARN,
      user_data = {
        lsp = {
          code = 'E302',
        }
      }
    }
    assert.are.same(expected_error, result[1])
    local expected_warning = {
      code = 'W291',
      source = 'pycodestyle',
      message = 'trailing whitespace',
      lnum = 68,
      end_lnum = 68,
      col = 47,
      end_col = 47,
      severity = vim.diagnostic.severity.WARN,
      user_data = {
        lsp = {
          code = 'W291',
        }
      }
    }
    assert.are.same(expected_warning, result[3])
  end)
end)
