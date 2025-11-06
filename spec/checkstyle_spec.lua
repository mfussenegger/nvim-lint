describe('linter.checkstyle', function()
  it('can parse the output', function()
    local bufnr = vim.uri_to_bufnr("file:///Planner.java")
    local parser = require('lint.linters.checkstyle').parser
    local output = [[
{
  "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {
        "driver": {
          "downloadUri": "https://github.com/checkstyle/checkstyle/releases/",
          "fullName": "Checkstyle",
          "informationUri": "https://checkstyle.org/",
          "language": "en",
          "name": "Checkstyle",
          "organization": "Checkstyle",
          "rules": [],
          "semanticVersion": "10.4",
          "version": "10.4"
        }
      },
      "results": [
        {
          "level": "error",
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "file:///Planner.java"
                },
                "region": {
                  "startColumn": 19,
                  "startLine": 176
                }
              }
            }
          ],
          "message": {
            "text": "'static' modifier out of order with the JLS suggestions."
          },
          "ruleId": "mod.order"
        }
      ]
    }
  ]
}
    ]]
    local result = parser(output, bufnr, vim.fn.getcwd())
    assert.are.same(1, #result)
    local expected = {
      source = 'Checkstyle',
      message = "'static' modifier out of order with the JLS suggestions.",
      lnum = 175,
      col = 18,
      end_col = require("lint.parser").maxint,
      severity = vim.diagnostic.severity.ERROR,
      code = "mod.order"
    }
    assert.are.same(expected, result[1])
  end)
end)
