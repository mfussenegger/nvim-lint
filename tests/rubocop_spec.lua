describe('linter.rubocop', function()
  it('can parse rubocop output', function()
    local parser = require('lint.linters.rubocop').parser
    local result = parser([[
{
  "files": [
    {
      "path": "test.rb",
      "offenses": [
        {
          "severity": "convention",
          "message": "Use snake_case for method names.",
          "cop_name": "Naming/MethodName",
          "corrected": false,
          "correctable": false,
          "location": {
            "start_line": 3,
            "start_column": 5,
            "last_line": 3,
            "last_column": 11,
            "length": 7,
            "line": 3,
            "column": 5
          }
        },
        {
          "severity": "warning",
          "message": "Useless assignment to variable - `foo`.",
          "cop_name": "Lint/UselessAssignment",
          "corrected": false,
          "correctable": false,
          "location": {
            "start_line": 4,
            "start_column": 3,
            "last_line": 4,
            "last_column": 5,
            "length": 3,
            "line": 4,
            "column": 3
          }
        }
      ]
    }
  ]
}
]])

    assert.are.same(2, #result)

    local expected_1 = {
      source = 'rubocop',
      lnum = 2,
      col = 4,
      end_lnum = 2,
      end_col = 11,
      severity = vim.diagnostic.severity.HINT,
      message = 'Use snake_case for method names.',
      code = 'Naming/MethodName',
    }

    assert.are.same(expected_1, result[1])

    local expected_2 = {
      source = 'rubocop',
      lnum = 3,
      col = 2,
      end_lnum = 3,
      end_col = 5,
      severity = vim.diagnostic.severity.WARN,
      message = 'Useless assignment to variable - `foo`.',
      code = 'Lint/UselessAssignment',
    }

    assert.are.same(expected_2, result[2])
  end)

  it('can handle rubocop excluding the file', function()
    local parser = require('lint.linters.rubocop').parser
    local result = parser([[{ "files": [] }]])
    assert.are.same(0, #result)
  end)
end)
