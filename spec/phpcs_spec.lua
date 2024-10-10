describe('linter.phpcs', function()
  it('ignores empty output', function()
    local parser = require('lint.linters.phpcs').parser

    assert.are.same({}, parser('', vim.api.nvim_get_current_buf()))
    assert.are.same({}, parser('  ', vim.api.nvim_get_current_buf()))
  end)

  it('parses json output correctly', function()
    local parser = require('lint.linters.phpcs').parser
    -- json sourced from sample here: https://github.com/squizlabs/PHP_CodeSniffer/wiki/Reporting#printing-a-json-report
    -- slightly modified for STDIN result format
    local result = parser([[
{
  "totals": {
    "errors": 4,
    "warnings": 1,
    "fixable": 3
  },
  "files": {
    "STDIN": {
      "errors": 4,
      "warnings": 1,
      "messages": [
        {
          "message": "Missing file doc comment",
          "source": "PEAR.Commenting.FileComment.Missing",
          "severity": 5,
          "type": "ERROR",
          "line": 2,
          "column": 1,
          "fixable": false
        },
        {
          "message": "TRUE, FALSE and NULL must be lowercase; expected \"false\" but found \"FALSE\"",
          "source": "Generic.PHP.LowerCaseConstant.Found",
          "severity": 5,
          "type": "ERROR",
          "line": 4,
          "column": 12,
          "fixable": true
        },
        {
          "message": "Line indented incorrectly; expected at least 4 spaces, found 1",
          "source": "PEAR.WhiteSpace.ScopeIndent.Incorrect",
          "severity": 5,
          "type": "ERROR",
          "line": 6,
          "column": 2,
          "fixable": true
        },
        {
          "message": "Missing function doc comment",
          "source": "PEAR.Commenting.FunctionComment.Missing",
          "severity": 5,
          "type": "ERROR",
          "line": 9,
          "column": 1,
          "fixable": false
        },
        {
          "message": "Inline control structures are discouraged",
          "source": "Generic.ControlStructures.InlineControlStructure.Discouraged",
          "severity": 5,
          "type": "WARNING",
          "line": 11,
          "column": 5,
          "fixable": true
        }
      ]
    }
  }
}
    ]], vim.api.nvim_get_current_buf())
    assert.are.same(5, #result)

    local expected = {
      lnum = 1,
      end_lnum = 1,
      col = 0,
      end_col = 0,
      message = 'Missing file doc comment',
      code = 'PEAR.Commenting.FileComment.Missing',
      source = 'phpcs',
      severity = vim.diagnostic.severity.ERROR
    }
    assert.are.same(expected, result[1])

    expected = {
      lnum = 10,
      end_lnum = 10,
      col = 4,
      end_col = 4,
      message = 'Inline control structures are discouraged',
      code = 'Generic.ControlStructures.InlineControlStructure.Discouraged',
      source = 'phpcs',
      severity = vim.diagnostic.severity.WARN,
    }
    assert.are.same(expected, result[5])
  end)
end)
