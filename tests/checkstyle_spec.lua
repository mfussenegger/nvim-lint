describe('linter.checkstyle', function()
  it('can parse the output', function()
    local parser = require('lint.linters.checkstyle').parser
    local result = parser([[
Starting audit...
[WARN] src/main/java/com/foo/bar/ApiClient.java:75:1: 'member def modifier' has incorrect indentation level 0, expected level should be 2. [Indentation]
[ERROR] src/main/java/com/foo/bar/ApiClient.java:187: Line is longer than 120 characters (found 143). [LineLength]
[ERROR] src/main/java/com/foo/bar/ApiClient.java:6:3: 'method def' child has incorrect indentation level 2, expected level should be 4. [Indentation]
Audit done.
Checkstyle ends with 1 errors.
]])
    assert.are.same(3, #result)
    local expected = {
      source = 'checkstyle',
      message = "'method def' child has incorrect indentation level 2, expected level should be 4. [Indentation]",
      lnum = 5,
      col = 2,
      end_lnum = 5,
      end_col = 2,
      severity = vim.diagnostic.severity.ERROR,
    }
    assert.are.same(expected, result[3])
    expected = {
      source = 'checkstyle',
      message = "Line is longer than 120 characters (found 143). [LineLength]",
      lnum = 186,
      col = 0,
      end_lnum = 186,
      end_col = 0,
      severity = vim.diagnostic.severity.ERROR,
    }
    assert.are.same(expected, result[2])
    expected = {
      source = 'checkstyle',
      message = "'member def modifier' has incorrect indentation level 0, expected level should be 2. [Indentation]",
      lnum = 74,
      col = 0,
      end_lnum = 74,
      end_col = 0,
      severity = vim.diagnostic.severity.WARN
    }
    assert.are.same(expected, result[1])
  end)
end)
