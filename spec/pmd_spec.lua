describe('linter.pmd', function()
  it('can parse the output', function()
    local bufnr = vim.uri_to_bufnr("file:///Planner.java")
    local parser = require('lint.linters.pmd').parser
    local output = [[
{
  "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {
        "driver": {
          "name": "PMD",
          "version": "7.12.0",
          "informationUri": "https://docs.pmd-code.org/latest/",
          "rules": [
            {
              "id": "GuardLogStatement",
              "shortDescription": {
                "text": "Logger calls should be surrounded by log level guards."
              },
              "fullDescription": {
                "text": "\nWhenever using a log level, one should check if it is actually enabled, or\notherwise skip the associate String creation and manipulation, as well as any method calls.\n\nAn alternative to checking the log level are substituting
parameters, formatters or lazy logging\nwith lambdas. The available alternatives depend on the actual logging framework.\n        "
              },
              "helpUri": "https://docs.pmd-code.org/snapshot/pmd_rules_java_bestpractices.html#guardlogstatement",
              "help": {
                "text": "\nWhenever using a log level, one should check if it is actually enabled, or\notherwise skip the associate String creation and manipulation, as well as any method calls.\n\nAn alternative to checking the log level are substituting
parameters, formatters or lazy logging\nwith lambdas. The available alternatives depend on the actual logging framework.\n        "
              },
              "properties": {
                "ruleset": "Best Practices",
                "priority": 2,
                "tags": [
                  "Best Practices"
                ]
              }
            }
          ]
        }
      },
      "results": [
        {
          "ruleId": "GuardLogStatement",
          "ruleIndex": 0,
          "message": {
            "text": "Logger calls should be surrounded by log level guards."
          },
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "file:///Planner.java"
                },
                "region": {
                  "startLine": 507,
                  "startColumn": 17,
                  "endLine": 509,
                  "endColumn": 144
                }
              }
            }
          ]
        }
      ],
      "invocations": [
        {
          "executionSuccessful": true,
          "toolConfigurationNotifications": [],
          "toolExecutionNotifications": []
        }
      ]
    }
  ]
}
    ]]
    local result = parser(output, bufnr, vim.fn.getcwd())
    assert.are.same(1, #result)
    local expected = {
      code = 'GuardLogStatement',
      col = 16,
      end_col = 142,
      end_lnum = 508,
      lnum = 506,
      message = 'Logger calls should be surrounded by log level guards.',
      severity = vim.diagnostic.severity.WARN,
      source = 'PMD'
    }
    assert.are.same(expected, result[1])
  end)
end)
