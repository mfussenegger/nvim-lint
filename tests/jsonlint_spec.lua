describe('linter.jsonlint', function()
  it('can parse the output', function()
    local parser = require('lint.linters.jsonlint').parser
    local result = parser([[
/some/folder/test.json: line 3, col 7, found: 'INVALID' - expected: 'EOF', '}', ':', ',', ']'.
test.json: line 5003, col 11, found: 'INVALID' - expected: 'STRING'.
]], vim.api.nvim_get_current_buf())
  assert.are.same(2, #result)

  local expected = {
    lnum = 2,
    end_lnum = 2,
    col = 6,
    end_col = 6,
    message = "found: 'INVALID' - expected: 'EOF', '}', ':', ',', ']'.",
    severity = vim.diagnostic.severity.ERROR,
    source = "jsonlint",
  }
  assert.are.same(expected, result[1])

  expected = {
    lnum = 5002,
    end_lnum = 5002,
    col = 10,
    end_col = 10,
    message = "found: 'INVALID' - expected: 'STRING'.",
    severity = vim.diagnostic.severity.ERROR,
    source = "jsonlint",
  }
  assert.are.same(expected, result[2])
end)
end)
