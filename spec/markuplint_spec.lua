describe("linter.markuplint", function()
  it("can parse the output", function()
    local parser = require("lint.linters.markuplint").parser
    local output = [[
[
  {
    "severity": "error",
    "message": "The value of the \"id\" attribute is duplicated",
    "line": 12,
    "col": 8,
    "raw": "id=\"root\"",
    "ruleId": "id-duplication",
    "filePath": "/test/index.html"
  },
  {
    "severity": "warning",
    "message": "Require the \"h1\" element",
    "line": 1,
    "col": 1,
    "raw": "<",
    "ruleId": "required-h1",
    "filePath": "/test/index.html"
  }
]
]]

    local result = parser(output)
    assert.are.same(2, #result)

    local expected = {
      lnum = 11,
      col = 7,
      message = 'The value of the "id" attribute is duplicated',
      severity = vim.diagnostic.severity.ERROR,
      code = "id-duplication",
      source = "markuplint",
    }
    assert.are.same(expected, result[1])

    expected = {
      lnum = 0,
      col = 0,
      message = 'Require the "h1" element',
      severity = vim.diagnostic.severity.WARN,
      code = "required-h1",
      source = "markuplint",
    }
    assert.are.same(expected, result[2])
  end)
end)
