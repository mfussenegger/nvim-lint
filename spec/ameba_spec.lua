describe("linter.ameba", function()
  it("can parse ameba output", function()
    local parser = require("lint.linters.ameba").parser
    local result = parser([[
{
  "sources": [
    {
      "path": "src/test.cr",
      "issues": [
        {
          "rule_name": "Lint/RedundantStringCoercion",
          "severity": "Warning",
          "message": "Redundant use of `Object#to_s` in interpolation",
          "location": {
            "line": 77,
            "column": 61
          },
          "end_location": {
            "line": 77,
            "column": 64
          }
        },
        {
          "rule_name": "Style/RedundantReturn",
          "severity": "Convention",
          "message": "Redundant `return` detected",
          "location": {
            "line": 85,
            "column": 7
          },
          "end_location": {
            "line": 85,
            "column": 26
          }
        }
      ]
    }
  ],
  "metadata": {
    "ameba_version": "1.6.1",
    "crystal_version": "1.12.1"
  },
  "summary": {
    "target_sources_count": 1,
    "issues_count": 2
  }
}
]])

    assert.are.same(2, #result)

    local expected_1 = {
      source = "ameba",
      lnum = 76,
      col = 60,
      end_lnum = 76,
      end_col = 64,
      severity = vim.diagnostic.severity.WARN,
      message = "Redundant use of `Object#to_s` in interpolation",
      code = "Lint/RedundantStringCoercion",
    }

    assert.are.same(expected_1, result[1])

    local expected_2 = {
      source = "ameba",
      lnum = 84,
      col = 6,
      end_lnum = 84,
      end_col = 26,
      severity = vim.diagnostic.severity.HINT,
      message = "Redundant `return` detected",
      code = "Style/RedundantReturn",
    }

    assert.are.same(expected_2, result[2])
  end)

  it("can handle ameba excluding the file", function()
    local parser = require("lint.linters.ameba").parser
    local result = parser([[{ "sources": [] }]])
    assert.are.same(0, #result)
  end)
end)
