describe('linter.checkstyle', function()
  it('can parse the output', function()
    local parser = require('lint.linters.checkstyle').parser
    local result = parser([[
Starting audit...
[WARN] src/main/java/com/foo/bar/ApiClient.java:75:1: 'member def modifier' has incorrect indentation level 0, expected level should be 2. [Indentation]
[ERROR] src/main/java/com/foo/bar/ApiClient.java:187: Line is longer than 120 characters (found 143). [LineLength]
Audit done.
Checkstyle ends with 1 errors.
]])
    assert.are.same(2, #result)
    local expected = {
      source = 'checkstyle',
      message = "Line is longer than 120 characters (found 143). [LineLength]",
      range = {
        ['start'] = {
          character = 0,
          line = 186,
        },
        ['end'] = {
          character = 0,
          line = 186,
        },
      },
    }
    assert.are.same(expected, result[2])
    local expected = {
      source = 'checkstyle',
      message = "'member def modifier' has incorrect indentation level 0, expected level should be 2. [Indentation]",
      range = {
        ['start'] = {
          character = 0,
          line = 74,
        },
        ['end'] = {
          character = 0,
          line = 74,
        },
      },
    }
    assert.are.same(expected, result[1])
  end)
end)
