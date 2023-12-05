describe('linter.prisma-lint', function()
  it('can parse prisma-lint output', function()
    local parser = require('lint.linters.prisma-lint').parser
    local result = parser([[
{
  "violations": [
    {
      "ruleName": "model-name-mapping-snake-case",
      "message": "Model name must be mapped to \"user\".",
      "fileName": "/example/invalid-simple.prisma",
      "location": {
        "startLine": 1,
        "startColumn": 1,
        "endLine": 1,
        "endColumn": 12
      }
    },
    {
      "ruleName": "require-field",
      "message": "Missing required fields: \"createdAt\".",
      "fileName": "/example/invalid-simple.prisma",
      "location": {
        "startLine": 1,
        "startColumn": 1,
        "endLine": 1,
        "endColumn": 12
      }
    },
    {
      "ruleName": "field-name-mapping-snake-case",
      "message": "Field name must be mapped to snake case.",
      "fileName": "/example/invalid-simple.prisma",
      "location": {
        "startLine": 3,
        "startColumn": 3,
        "endLine": 3,
        "endColumn": 8
      }
    }
  ]
}
]])

    assert.are.same(3, #result)

    local expected_1 = {
      source = 'prisma-lint',
      lnum = 0,
      col = 0,
      end_lnum = 0,
      end_col = 12,
      severity = vim.diagnostic.severity.ERROR,
      message = 'Model name must be mapped to "user".',
      code = 'model-name-mapping-snake-case',
    }

    assert.are.same(expected_1, result[1])

    local expected_2 = {
      source = 'prisma-lint',
      lnum = 0,
      col = 0,
      end_lnum = 0,
      end_col = 12,
      severity = vim.diagnostic.severity.ERROR,
      message = 'Missing required fields: "createdAt".',
      code = 'require-field',
    }

    assert.are.same(expected_2, result[2])

    local expected_3 = {
      source = 'prisma-lint',
      lnum = 2,
      col = 2,
      end_lnum = 2,
      end_col = 8,
      severity = vim.diagnostic.severity.ERROR,
      message = 'Field name must be mapped to snake case.',
      code = 'field-name-mapping-snake-case',
    }

    assert.are.same(expected_3, result[3])
  end)
end)
