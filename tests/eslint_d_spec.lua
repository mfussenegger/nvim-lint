describe("linter.eslint_d", function()
  it("should ignore empty output", function()
    local parser = require("lint.linters.eslint_d").parser

    assert.are.same({}, parser("", vim.api.nvim_get_current_buf()))
    assert.are.same({}, parser("  ", vim.api.nvim_get_current_buf()))
  end)

  it('should gracefully handle invalid JSON', function()
    local parser = require("lint.linters.eslint_d").parser

    local json = '{]'
    local result = parser(json)
    local expected = {
      {
        lnum = 0,
        col = 0,
        message = "Could not parse linter output due to: Expected object key string but found T_ARR_END at character 2\noutput: {]",
        source = "eslint_d",
      }
    }
    assert.are.same(expected, result)
  end)

  it('uses 0 defaults for missing line/column', function()
    local parser = require("lint.linters.eslint_d").parser
    local json = '[{ "messages": [' ..
        -- Valid JSON diagnostic.
        [[
          {
            "column": 4,
            "endColumn": 8,
            "line": 1,
            "endLine": 1,
            "message": "foo message",
            "ruleId": "foo",
            "severity": 2
          },
        ]] ..
        -- JSON diagnostic with missing line.
        [[
          {
            "column": 4,
            "endColumn": 8,
            "endLine": 1,
            "message": "bar message",
            "ruleId": "bar",
            "severity": 2
          },
        ]] ..
        -- JSON diagnostic with missing column.
        [[
          {
            "endColumn": 8,
            "line": 1,
            "endLine": 1,
            "message": "baz message",
            "ruleId": "baz",
            "severity": 2
          }
        ]] .. ']}]'
    local result = parser(json)

    assert.are.same(3, #result)
    assert.are.same(0, result[2].lnum)
    assert.are.same(0, result[3].col)
  end)

  it('should show fatal diagnostics on the first line', function()
    local parser = require("lint.linters.eslint_d").parser

    local json = '[{ "messages": [ { "fatal": true, "message": "fatal", "severity": 2 } ]}]'
    local result = parser(json)

    assert.are.same(1, #result)
    assert.are.same({
      col = 0,
      lnum = 0,
      message = "fatal",
      severity = vim.diagnostic.severity.ERROR,
      source = "eslint_d"
    }, result[1])
  end)

  it('should parse valid diagnostics', function()
    local parser = require("lint.linters.eslint_d").parser

    local json = '[{ "messages": [' ..
        -- JSON diagnostic with warn severity.
        [[
          {
            "column": 4,
            "endColumn": 8,
            "line": 12,
            "endLine": 14,
            "message": "foo message",
            "ruleId": "foo",
            "severity": 1
          },
        ]] ..
        -- JSON diagnostic with error serverity.
        [[
          {
            "column": 16,
            "endColumn": 78,
            "line": 8,
            "endLine": 8,
            "message": "bar message",
            "ruleId": "bar",
            "severity": 2
          },
        ]] ..
        -- JSON diagnostic without ruleId.
        [[
          {
            "column": 40,
            "endColumn": 78,
            "line": 122,
            "endLine": 124,
            "message": "baz message",
            "severity": 2
          },
        ]] ..
        -- JSON diagnostic without end values,
        [[
          {
            "column": 36,
            "line": 92,
            "message": "qux message",
            "ruleId": "qux",
            "severity": 2
          }
        ]] .. ']}]'
    local result = parser(json)

    assert.are.same(4, #result)
    assert.are.same({
      code = "foo",
      col = 3,
      end_col = 7,
      end_lnum = 13,
      lnum = 11,
      message = "foo message",
      severity = vim.diagnostic.severity.WARN,
      source = "eslint_d"
    }, result[1])
    assert.are.same({
      code = "bar",
      col = 15,
      end_col = 77,
      end_lnum = 7,
      lnum = 7,
      message = "bar message",
      severity = vim.diagnostic.severity.ERROR,
      source = "eslint_d"
    }, result[2])
    assert.are.same({
      col = 39,
      end_col = 77,
      end_lnum = 123,
      lnum = 121,
      message = "baz message",
      severity = vim.diagnostic.severity.ERROR,
      source = "eslint_d"
    }, result[3])
    assert.are.same({
      code = "qux",
      col = 35,
      lnum = 91,
      message = "qux message",
      severity = vim.diagnostic.severity.ERROR,
      source = "eslint_d"
    }, result[4])
  end)
end)
