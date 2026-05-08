describe('linter.herb', function()
  it('can parse the output', function()
    local parser = require('lint.linters.herb').parser
    local result = parser([[
{
  "offenses": [
    {
      "code": "ERB001",
      "message": "Missing closing tag for <div>",
      "severity": "error",
      "location": {
        "start": { "line": 3, "column": 2 },
        "end": { "line": 3, "column": 7 }
      }
    },
    {
      "code": "ERB002",
      "message": "Unexpected whitespace",
      "severity": "warning",
      "location": {
        "start": { "line": 10, "column": 4 },
        "end": { "line": 10, "column": 8 }
      }
    }
  ]
}
]], vim.api.nvim_get_current_buf())
    assert.are.same(2, #result)

    local expected = {
      lnum = 2,
      col = 2,
      end_lnum = 2,
      end_col = 7,
      message = "Missing closing tag for <div>",
      code = "ERB001",
      severity = vim.diagnostic.severity.ERROR,
      source = "herb-lint",
    }
    assert.are.same(expected, result[1])

    expected = {
      lnum = 9,
      col = 4,
      end_lnum = 9,
      end_col = 8,
      message = "Unexpected whitespace",
      code = "ERB002",
      severity = vim.diagnostic.severity.WARN,
      source = "herb-lint",
    }
    assert.are.same(expected, result[2])
  end)

  it('returns empty when output is empty', function()
    local parser = require('lint.linters.herb').parser
    local result = parser('', vim.api.nvim_get_current_buf())
    assert.are.same({}, result)
  end)

  it('returns empty when output is invalid json', function()
    local parser = require('lint.linters.herb').parser
    local result = parser('not json', vim.api.nvim_get_current_buf())
    assert.are.same({}, result)
  end)
end)
