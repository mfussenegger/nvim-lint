describe('linter.markdownlint', function()
  it('can parse the output', function()
    local parser = require('lint.linters.markdownlint').parser
    local result = parser([[
README.md:35 MD022/blanks-around-headings/blanks-around-headers Headings should be surrounded by blank lines [Expected: 1; Actual: 0; Below] [Context: "## What's in this repo?"]
README.md:36 MD032/blanks-around-lists Lists should be surrounded by blank lines [Context: "- `dotfiles`"]
README.md:47:81 MD013/line-length Line length [Expected: 80; Actual: 114]
README.md:55:81 MD013/line-length Line length [Expected: 80; Actual: 244]
]])
  assert.are.same(4, #result)
  local expected = {
    source = 'markdownlint',
    message = 'MD022/blanks-around-headings/blanks-around-headers Headings should be surrounded by blank lines [Expected: 1; Actual: 0; Below] [Context: "## What\'s in this repo?"]',
    lnum = 34,
    col = 0,
    end_lnum = 34,
    end_col = 0,
    severity = vim.diagnostic.severity.WARN,
  }
  assert.are.same(expected, result[1])

  expected = {
    source = 'markdownlint',
    message = 'MD013/line-length Line length [Expected: 80; Actual: 114]',
    lnum = 46,
    col = 80,
    end_lnum = 46,
    end_col = 80,
    severity = vim.diagnostic.severity.WARN,
  }
  assert.are.same(expected, result[3])
  end)
end)
