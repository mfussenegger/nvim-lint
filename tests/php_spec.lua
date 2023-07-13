describe('linter.php', function()
  it("doesn't error on empty output", function()
    local parser = require('lint.linters.php').parser
    parser('')
    parser('  ')
  end)

  it("handles the default output when there are no errors or warnings", function()
    local parser = require('lint.linters.php').parser
    local result = parser('No syntax errors detected in Standard input code')
    assert.are.same(0, #result)
  end)

  it("handles warnings in the output", function()
    local parser = require('lint.linters.php').parser
    local result = parser([[

Warning: The use statement with non-compound name 'Foo' has no effect in Standard input code on line 3


Warning: The use statement with non-compound name 'Bar' has no effect in Standard input code on line 4

No syntax errors detected in Standard input code
    ]], vim.api.nvim_get_current_buf())
    assert.are.same(2, #result)

    local expected = {
      lnum = 2,
      end_lnum = 2,
      col = 0,
      end_col = 0,
      message = 'The use statement with non-compound name \'Foo\' has no effect',
      source = 'php',
      severity = vim.diagnostic.severity.WARN
    }
    assert.are.same(expected, result[1])

    expected = {
      lnum = 3,
      end_lnum = 3,
      col = 0,
      end_col = 0,
      message = 'The use statement with non-compound name \'Bar\' has no effect',
      source = 'php',
      severity = vim.diagnostic.severity.WARN
    }
    assert.are.same(expected, result[2])
  end)

  it("handles a parse error in the output", function()
    local parser = require('lint.linters.php').parser
    local result = parser([[

Parse error: syntax error, unexpected token "function", expecting "," or ";" in Standard input code on line 9

Errors parsing Standard input code
    ]], vim.api.nvim_get_current_buf())
    assert.are.same(1, #result)

    local expected = {
      lnum = 8,
      end_lnum = 8,
      col = 0,
      end_col = 0,
      message = 'syntax error, unexpected token "function", expecting "," or ";"',
      source = 'php',
      severity = vim.diagnostic.severity.ERROR
    }
    assert.are.same(expected, result[1])
  end)

  it("handles a fatal error in the output", function()
    local parser = require('lint.linters.php').parser
    local result = parser([[

Fatal error: Unparenthesized `a ? b : c ? d : e` is not supported. Use either `(a ? b : c) ? d : e` or `a ? b : (c ? d : e)` in Standard input code on line 3

Errors parsing Standard input code
    ]], vim.api.nvim_get_current_buf())
    assert.are.same(1, #result)

    local expected = {
      lnum = 2,
      end_lnum = 2,
      col = 0,
      end_col = 0,
      message = 'Unparenthesized `a ? b : c ? d : e` is not supported. Use either `(a ? b : c) ? d : e` or `a ? b : (c ? d : e)`',
      source = 'php',
      severity = vim.diagnostic.severity.ERROR
    }
    assert.are.same(expected, result[1])
  end)

  it("handles a deprecation notices in the output", function()
    local parser = require('lint.linters.php').parser
    local result = parser([[

Deprecated: Optional parameter $a declared before required parameter $b is implicitly treated as a required parameter in Standard input code on line 3

No syntax errors detected in Standard input code
    ]], vim.api.nvim_get_current_buf())
    assert.are.same(1, #result)

    local expected = {
      lnum = 2,
      end_lnum = 2,
      col = 0,
      end_col = 0,
      message = 'Optional parameter $a declared before required parameter $b is implicitly treated as a required parameter',
      source = 'php',
      severity = vim.diagnostic.severity.INFO
    }
    assert.are.same(expected, result[1])
  end)

end)
