describe('linter.pylint', function()
  it('can parse pylint output', function()
    local parser = require('lint.linters.pylint').parser
    local bufnr = vim.uri_to_bufnr('file:///two.py')
    local result = parser([[
[
  {
    "type": "warning",
    "module": "two",
    "obj": "",
    "line": 4,
    "column": 0,
    "path": "/two.py",
    "symbol": "bad-indentation",
    "message": "Bad indentation. Found 2 spaces, expected 4",
    "message-id": "W0311"
  },
  {
    "type": "convention",
    "module": "two",
    "obj": "",
    "line": 1,
    "column": 0,
    "path": "/two.py",
    "symbol": "missing-module-docstring",
    "message": "Missing module docstring",
    "message-id": "C0114"
  },
  {
    "type": "refactor",
    "module": "two",
    "obj": "",
    "line": 3,
    "column": 3,
    "path": "/two.py",
    "symbol": "comparison-with-itself",
    "message": "Redundant comparison - 1 == 1",
    "message-id": "R0124"
  }
]
]], bufnr)

    assert.are.same(3, #result)

    local expected_1 = {
      message = 'Bad indentation. Found 2 spaces, expected 4',
      lnum = 3,
      col = 0,
      end_lnum = 3,
      end_col = 0,
      severity = vim.diagnostic.severity.WARN,
    }

    assert.are.same(expected_1, result[1])

    local expected_2 = {
      message = 'Missing module docstring',
      lnum = 0,
      col = 0,
      end_lnum = 0,
      end_col = 0,
      severity = vim.diagnostic.severity.HINT,
    }

    assert.are.same(expected_2, result[2])

    local expected_3 = {
      message = 'Redundant comparison - 1 == 1',
      lnum = 2,
      col = 2,
      end_lnum = 2,
      end_col = 2,
      severity = vim.diagnostic.severity.INFO,
    }

    assert.are.same(expected_3, result[3])
  end)
end)
