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
  },
  {
    "type": "warning",
    "module": "two",
    "obj": "",
    "line": 5,
    "column": 4,
    "endLine": 5,
    "endColumn": 8,
    "path": "/two.py",
    "symbol": "unused-variable",
    "message": "Unused variable 'test'",
    "message-id": "W0612"
  }
]
]], bufnr)

    assert.are.same(4, #result)

    local expected_1 = {
      source = 'pylint',
      message = 'Bad indentation. Found 2 spaces, expected 4',
      lnum = 3,
      col = 0,
      end_lnum = 3,
      end_col = 0,
      severity = vim.diagnostic.severity.WARN,
      code = 'W0311',
      user_data = {
        lsp = {
          code = 'W0311',
        },
      },
    }

    assert.are.same(expected_1, result[1])

    local expected_2 = {
      source = 'pylint',
      message = 'Missing module docstring',
      lnum = 0,
      col = 0,
      end_lnum = 0,
      end_col = 0,
      severity = vim.diagnostic.severity.HINT,
      code = 'C0114',
      user_data = {
        lsp = {
          code = 'C0114',
        },
      },
    }

    assert.are.same(expected_2, result[2])

    local expected_3 = {
      source = 'pylint',
      message = 'Redundant comparison - 1 == 1',
      lnum = 2,
      col = 3,
      end_lnum = 2,
      end_col = 3,
      severity = vim.diagnostic.severity.INFO,
      code = 'R0124',
      user_data = {
        lsp = {
          code = 'R0124',
        },
      },
    }

    assert.are.same(expected_3, result[3])

    local expected_4 = {
      source = 'pylint',
      message = "Unused variable 'test'",
      lnum = 4,
      col = 4,
      end_lnum = 4,
      end_col = 8,
      severity = vim.diagnostic.severity.WARN,
      code = 'W0612',
      user_data = {
        lsp = {
          code = 'W0612',
        },
      },
    }

    assert.are.same(expected_4, result[4])
  end)
end)
