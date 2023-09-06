describe('linter.twigcs', function()
  it('ignores empty output', function()
    local parser = require('lint.linters.twigcs').parser

    assert.are.same({}, parser('', vim.api.nvim_get_current_buf()))
    assert.are.same({}, parser('  ', vim.api.nvim_get_current_buf()))
  end)

  it('parses emacs output correctly', function()
    local parser = require('lint.linters.twigcs').parser

    local result = parser([[/Users/dblanken/code/testcode/test.twig:2:15: error - Should have 1 argument.
/Users/dblanken/code/testcode/test.twig:4:2: error - Another problem.]], vim.api.nvim_get_current_buf())

    assert.are.same(2, #result)

    local expected = {
      col = 14,
      end_col = 14,
      lnum = 1,
      end_lnum = 1,
      message = 'Should have 1 argument.',
      severity = 1,
      source = 'twigcs',
    }
    assert.are.same(expected, result[1])

    expected = {
      col = 1,
      end_col = 1,
      lnum = 3,
      end_lnum = 3,
      message = 'Another problem.',
      severity = 1,
      source = 'twigcs',
    }
    assert.are.same(expected, result[2])
  end)
end)
