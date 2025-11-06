local bufnr = vim.uri_to_bufnr("file:///foo.java")
local api = vim.api
local parser = require("lint.parser")

describe("for_sarif", function()
  it("ignores results for other buffers", function()
    local parse = parser.for_sarif({})
    local output = [[
{
  "$schema": "https://docs.oasis-open.org/sarif/sarif/v2.1.0/errata01/os/schemas/sarif-schema-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {
        "driver": {
          "language": "en",
          "name": "SpecTool"
        }
      },
      "results": [
        {
          "level": "warning",
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "file:///foo.java"
                },
                "region": {
                  "startColumn": 10,
                  "startLine": 1
                }
              }
            }
          ],
          "message": {
            "text": "This is a placeholder message."
          },
          "ruleId": "placeholder.code"
        },
        {
          "level": "warning",
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "file:///other.java"
                },
                "region": {
                  "startColumn": 10,
                  "startLine": 1
                }
              }
            }
          ],
          "message": {
            "text": "This is a placeholder message."
          },
          "ruleId": "placeholder.code"
        }
      ]
    }
  ]
}
    ]]
    local result = parse(output, bufnr, vim.fn.getcwd())
    assert.are.same(1, #result)

    assert.are.same({
      lnum = 0,
      col = 9,
      end_col = parser.maxint,
      severity = vim.diagnostic.severity.WARN,
      message = "This is a placeholder message.",
      source = "SpecTool",
      code = "placeholder.code",
    }, result[1])
  end)

  it("creates diagnostics for all runs", function()
    local parse = parser.for_sarif({})
    local output = [[
{
  "$schema": "https://docs.oasis-open.org/sarif/sarif/v2.1.0/errata01/os/schemas/sarif-schema-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {
        "driver": {
          "language": "en",
          "name": "SpecTool"
        }
      },
      "results": [
        {
          "level": "warning",
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "file:///foo.java"
                },
                "region": {
                  "startColumn": 10,
                  "startLine": 1
                }
              }
            }
          ],
          "message": {
            "text": "This is a placeholder message."
          },
          "ruleId": "placeholder.code"
        }
      ]
    },
    {
      "tool": {
        "driver": {
          "language": "en",
          "name": "SpecTool2"
        }
      },
      "results": [
        {
          "level": "warning",
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "file:///foo.java"
                },
                "region": {
                  "startColumn": 10,
                  "startLine": 1
                }
              }
            }
          ],
          "message": {
            "text": "This is another placeholder message."
          },
          "ruleId": "placeholder.code.two"
        }
      ]
    }
  ]
}
    ]]
    local result = parse(output, bufnr, vim.fn.getcwd())

    assert.are.same(2, #result)

    assert.are.same({
      lnum = 0,
      col = 9,
      end_col = parser.maxint,
      severity = vim.diagnostic.severity.WARN,
      message = "This is a placeholder message.",
      source = "SpecTool",
      code = "placeholder.code",
    }, result[1])

    assert.are.same({
      lnum = 0,
      col = 9,
      end_col = parser.maxint,
      severity = vim.diagnostic.severity.WARN,
      message = "This is another placeholder message.",
      source = "SpecTool2",
      code = "placeholder.code.two",
    }, result[2])
  end)

  it("creates diagnostics for all locations in a result", function()
    local parse = parser.for_sarif({})
    local output = [[
{
  "$schema": "https://docs.oasis-open.org/sarif/sarif/v2.1.0/errata01/os/schemas/sarif-schema-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {
        "driver": {
          "language": "en",
          "name": "SpecTool"
        }
      },
      "results": [
        {
          "level": "warning",
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "file:///foo.java"
                },
                "region": {
                  "startColumn": 10,
                  "startLine": 1
                }
              }
            },
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "file:///foo.java"
                },
                "region": {
                  "startColumn": 15,
                  "startLine": 20
                }
              }
            }
          ],
          "message": {
            "text": "This is a placeholder message."
          },
          "ruleId": "placeholder.code"
        }
      ]
    }
  ]
}
    ]]
    local result = parse(output, bufnr, vim.fn.getcwd())
    assert.are.same(2, #result)

    assert.are.same({
      lnum = 0,
      col = 9,
      end_col = parser.maxint,
      severity = vim.diagnostic.severity.WARN,
      message = "This is a placeholder message.",
      source = "SpecTool",
      code = "placeholder.code",
    }, result[1])

    assert.are.same({
      lnum = 19,
      col = 14,
      end_col = parser.maxint,
      severity = vim.diagnostic.severity.WARN,
      message = "This is a placeholder message.",
      source = "SpecTool",
      code = "placeholder.code",
    }, result[2])
  end)

  it("creates diagnostics spanning to the end of the line, without endCol", function()
    local parse = parser.for_sarif({})
    local output = [[
{
  "$schema": "https://docs.oasis-open.org/sarif/sarif/v2.1.0/errata01/os/schemas/sarif-schema-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {
        "driver": {
          "language": "en",
          "name": "SpecTool"
        }
      },
      "results": [
        {
          "level": "warning",
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "file:///foo.java"
                },
                "region": {
                  "startColumn": 10,
                  "startLine": 1
                }
              }
            }
          ],
          "message": {
            "text": "This is a placeholder message."
          },
          "ruleId": "placeholder.code"
        }
      ]
    }
  ]
}
    ]]
    local result = parse(output, bufnr, vim.fn.getcwd())
    assert.are.same(1, #result)
    assert.are.same({
      lnum = 0,
      col = 9,
      end_col = 2 ^ 32 - 1,
      severity = vim.diagnostic.severity.WARN,
      message = "This is a placeholder message.",
      source = "SpecTool",
      code = "placeholder.code",
    }, result[1])

    local ns = api.nvim_create_namespace("dummy")
    vim.diagnostic.set(ns, bufnr, result)
    api.nvim_buf_call(bufnr, function()
      vim.diagnostic.setloclist()
    end)
  end)

  it("creates diagnostics spanning to the end column, with endCol", function()
    local parse = parser.for_sarif({})
    local output = [[
{
  "$schema": "https://docs.oasis-open.org/sarif/sarif/v2.1.0/errata01/os/schemas/sarif-schema-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {
        "driver": {
          "language": "en",
          "name": "SpecTool"
        }
      },
      "results": [
        {
          "level": "warning",
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "file:///foo.java"
                },
                "region": {
                  "endColumn": 20,
                  "startColumn": 10,
                  "startLine": 1
                }
              }
            }
          ],
          "message": {
            "text": "This is a placeholder message."
          },
          "ruleId": "placeholder.code"
        }
      ]
    }
  ]
}
    ]]
    local result = parse(output, bufnr, vim.fn.getcwd())
    assert.are.same(1, #result)
    assert.are.same({
      lnum = 0,
      col = 9,
      end_col = 18,
      severity = vim.diagnostic.severity.WARN,
      message = "This is a placeholder message.",
      source = "SpecTool",
      code = "placeholder.code",
    }, result[1])
  end)
end)
