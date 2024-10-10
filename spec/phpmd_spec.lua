describe('linter.phpmd', function()
  it("doesn't error on empty output", function()
    local parser = require('lint.linters.phpmd').parser
    parser('')
    parser('  ')
  end)

  it("handles the default JSON output when there are no coding violations", function()
    local parser = require('lint.linters.phpmd').parser
    local result = parser([[
{
    "version": "@package_version@",
    "package": "phpmd",
    "timestamp": "2023-07-12T20:09:31+01:00",
    "files": []
}
    ]], vim.api.nvim_get_current_buf())
    assert.are.same(0, #result)
  end)

  it('parses json output correctly', function()
    local parser = require('lint.linters.phpmd').parser
    local result = parser([[
{
    "version": "@package_version@",
    "package": "phpmd",
    "timestamp": "2023-07-12T19:28:55+01:00",
    "files": [
        {
            "file": "php:\/\/stdin",
            "violations": [
                {
                    "beginLine": 11,
                    "endLine": 326,
                    "package": "Acme\\Example",
                    "function": null,
                    "class": "MyClass",
                    "method": null,
                    "description": "The class MyClass has an overall complexity of 61 which is very high. The configured complexity threshold is 50.",
                    "rule": "ExcessiveClassComplexity",
                    "ruleSet": "Code Size Rules",
                    "externalInfoUrl": "https:\/\/phpmd.org\/rules\/codesize.html#excessiveclasscomplexity",
                    "priority": 3
                },
                {
                    "beginLine": 125,
                    "endLine": 152,
                    "package": "Acme\\Example",
                    "function": null,
                    "class": "MyClass",
                    "method": "myMethod",
                    "description": "The method myMethod() has a Cyclomatic Complexity of 10. The configured cyclomatic complexity threshold is 10.",
                    "rule": "CyclomaticComplexity",
                    "ruleSet": "Code Size Rules",
                    "externalInfoUrl": "https:\/\/phpmd.org\/rules\/codesize.html#cyclomaticcomplexity",
                    "priority": 3
                },
                {
                    "beginLine": 146,
                    "endLine": 146,
                    "package": null,
                    "function": null,
                    "class": null,
                    "method": null,
                    "description": "Avoid excessively long variable names like $thisIsAVeryLongVariableName. Keep variable name length under 20.",
                    "rule": "LongVariable",
                    "ruleSet": "Naming Rules",
                    "externalInfoUrl": "https:\/\/phpmd.org\/rules\/naming.html#longvariable",
                    "priority": 3
                }
            ]
        }
    ]
}
    ]], vim.api.nvim_get_current_buf())
    assert.are.same(3, #result)

    local expected = {
      lnum = 10,
      end_lnum = 325,
      col = 0,
      end_col = 0,
      message = 'The class MyClass has an overall complexity of 61 which is very high. The configured complexity threshold is 50.',
      code = 'ExcessiveClassComplexity',
      source = 'phpmd',
      severity = vim.diagnostic.severity.INFO
    }
    assert.are.same(expected, result[1])

    expected = {
      lnum = 124,
      end_lnum = 151,
      col = 0,
      end_col = 0,
      message = 'The method myMethod() has a Cyclomatic Complexity of 10. The configured cyclomatic complexity threshold is 10.',
      code = 'CyclomaticComplexity',
      source = 'phpmd',
      severity = vim.diagnostic.severity.INFO,
    }
    assert.are.same(expected, result[2])

    expected = {
      lnum = 145,
      end_lnum = 145,
      col = 0,
      end_col = 0,
      message = 'Avoid excessively long variable names like $thisIsAVeryLongVariableName. Keep variable name length under 20.',
      code = 'LongVariable',
      source = 'phpmd',
      severity = vim.diagnostic.severity.INFO,
    }
    assert.are.same(expected, result[3])
  end)
end)
