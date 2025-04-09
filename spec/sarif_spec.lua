local function fname_to_bufnr(fname)
  return fname == "/home/someuser/Downloads/foo.java" and 1 or 42
end

describe("parser.sarif", function()
  describe("when given the default options", function()
    it("ignores results for different buffers", function()
      local parser = require("lint.parser").for_sarif({}, {
        fname_to_bufnr = fname_to_bufnr,
      })
      local result = parser(
        [[
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
                  "uri": "/home/someuser/Downloads/foo.java"
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
                  "uri": "/home/someuser/Downloads/bar.java"
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
]],
        1
      )

      assert.are.same(1, #result)

      assert.are.same({
        bufnr = 1,
        lnum = 0,
        col = 9,
        end_col = 999999,
        severity = vim.diagnostic.severity.WARN,
        message = "This is a placeholder message.",
        source = "SpecTool",
        code = "placeholder.code",
      }, result[1])
    end)

    it("creates diagnostics for all runs", function()
      local parser = require("lint.parser").for_sarif({}, {
        fname_to_bufnr = fname_to_bufnr,
      })
      local result = parser(
        [[
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
                  "uri": "/home/someuser/Downloads/foo.java"
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
                  "uri": "/home/someuser/Downloads/foo.java"
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
]],
        1
      )

      assert.are.same(2, #result)

      assert.are.same({
        bufnr = 1,
        lnum = 0,
        col = 9,
        end_col = 999999,
        severity = vim.diagnostic.severity.WARN,
        message = "This is a placeholder message.",
        source = "SpecTool",
        code = "placeholder.code",
      }, result[1])

      assert.are.same({
        bufnr = 1,
        lnum = 0,
        col = 9,
        end_col = 999999,
        severity = vim.diagnostic.severity.WARN,
        message = "This is another placeholder message.",
        source = "SpecTool2",
        code = "placeholder.code.two",
      }, result[2])
    end)

    it("creates diagnostics for all locations in a result", function()
      local parser = require("lint.parser").for_sarif({}, {
        fname_to_bufnr = fname_to_bufnr,
      })
      local result = parser(
        [[
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
                  "uri": "/home/someuser/Downloads/foo.java"
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
                  "uri": "/home/someuser/Downloads/foo.java"
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
]],
        1
      )

      assert.are.same(2, #result)

      assert.are.same({
        bufnr = 1,
        lnum = 0,
        col = 9,
        end_col = 999999,
        severity = vim.diagnostic.severity.WARN,
        message = "This is a placeholder message.",
        source = "SpecTool",
        code = "placeholder.code",
      }, result[1])

      assert.are.same({
        bufnr = 1,
        lnum = 19,
        col = 14,
        end_col = 999999,
        severity = vim.diagnostic.severity.WARN,
        message = "This is a placeholder message.",
        source = "SpecTool",
        code = "placeholder.code",
      }, result[2])
    end)

    it("creates diagnostics spanning to the end of the line, without endCol", function()
      local parser = require("lint.parser").for_sarif({}, {
        fname_to_bufnr = fname_to_bufnr,
      })
      local result = parser(
        [[
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
                  "uri": "/home/someuser/Downloads/foo.java"
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
]],
        1
      )

      assert.are.same(1, #result)

      assert.are.same({
        bufnr = 1,
        lnum = 0,
        col = 9,
        end_col = 999999,
        severity = vim.diagnostic.severity.WARN,
        message = "This is a placeholder message.",
        source = "SpecTool",
        code = "placeholder.code",
      }, result[1])
    end)

    it("creates diagnostics spanning to the end column, with endCol", function()
      local parser = require("lint.parser").for_sarif({}, {
        fname_to_bufnr = fname_to_bufnr,
      })
      local result = parser(
        [[
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
                  "uri": "/home/someuser/Downloads/foo.java"
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
]],
        1
      )

      assert.are.same(1, #result)

      assert.are.same({
        bufnr = 1,
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

  describe("when given the default_end_col option with '+1'", function()
    it("creates diagnostics without end_col, without endCol", function()
      local parser = require("lint.parser").for_sarif({}, {
        default_end_col = "+1",
        fname_to_bufnr = fname_to_bufnr,
      })
      local result = parser(
        [[
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
                  "uri": "/home/someuser/Downloads/foo.java"
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
]],
        1
      )

      assert.are.same(1, #result)

      assert.are.same({
        bufnr = 1,
        lnum = 0,
        col = 9,
        severity = vim.diagnostic.severity.WARN,
        message = "This is a placeholder message.",
        source = "SpecTool",
        code = "placeholder.code",
      }, result[1])
    end)

    it("creates diagnostics spanning to the end column, with endCol", function()
      local parser = require("lint.parser").for_sarif({}, {
        default_end_col = "+1",
        fname_to_bufnr = fname_to_bufnr,
      })
      local result = parser(
        [[
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
                  "uri": "/home/someuser/Downloads/foo.java"
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
]],
        1
      )

      assert.are.same(1, #result)

      assert.are.same({
        bufnr = 1,
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

  describe("when given a SARIF log in JSON format, generated by checkstyle", function()
    it("can parse the log with default options", function()
      local parser = require("lint.parser").for_sarif({}, {
        fname_to_bufnr = fname_to_bufnr,
      })
      local result = parser(
        [[
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
          "rules": [
          ],
          "semanticVersion": "10.12.6",
          "version": "10.12.6"
        }
      },
      "results": [
        {
          "level": "warning",
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "/home/someuser/Downloads/foo.java"
                },
                "region": {
                  "startColumn": 7,
                  "startLine": 1
                }
              }
            }
          ],
          "message": {
            "text": "Type name 'foo' must match pattern '^[A-Z][a-zA-Z0-9]*$'."
          },
          "ruleId": "name.invalidPattern"
        },
        {
          "level": "warning",
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "/home/someuser/Downloads/foo.java"
                },
                "region": {
                  "startColumn": 3,
                  "startLine": 3
                }
              }
            }
          ],
          "message": {
            "text": "'METHOD_DEF' should be separated from previous line."
          },
          "ruleId": "empty.line.separator"
        },
        {
          "level": "warning",
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "/home/someuser/Downloads/foo.java"
                },
                "region": {
                  "startColumn": 15,
                  "startLine": 3
                }
              }
            }
          ],
          "message": {
            "text": "Method Name 'foo' must not equal the enclosing class name."
          },
          "ruleId": "method.name.equals.class.name"
        },
        {
          "level": "warning",
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "/home/someuser/Downloads/foo.java"
                },
                "region": {
                  "startColumn": 19,
                  "startLine": 3
                }
              }
            }
          ],
          "message": {
            "text": "'(' is preceded with whitespace."
          },
          "ruleId": "ws.preceded"
        }
      ]
    }
  ]
}
]],
        1
      )

      assert.are.same(4, #result)

      assert.are.same({
        bufnr = 1,
        lnum = 0,
        col = 6,
        end_col = 999999,
        severity = vim.diagnostic.severity.WARN,
        message = "Type name 'foo' must match pattern '^[A-Z][a-zA-Z0-9]*$'.",
        source = "Checkstyle",
        code = "name.invalidPattern",
      }, result[1])

      assert.are.same({
        bufnr = 1,
        lnum = 2,
        col = 2,
        end_col = 999999,
        severity = vim.diagnostic.severity.WARN,
        message = "'METHOD_DEF' should be separated from previous line.",
        source = "Checkstyle",
        code = "empty.line.separator",
      }, result[2])

      assert.are.same({
        bufnr = 1,
        lnum = 2,
        col = 14,
        end_col = 999999,
        severity = vim.diagnostic.severity.WARN,
        message = "Method Name 'foo' must not equal the enclosing class name.",
        source = "Checkstyle",
        code = "method.name.equals.class.name",
      }, result[3])

      assert.are.same({
        bufnr = 1,
        lnum = 2,
        col = 18,
        end_col = 999999,
        severity = vim.diagnostic.severity.WARN,
        message = "'(' is preceded with whitespace.",
        source = "Checkstyle",
        code = "ws.preceded",
      }, result[4])
    end)
  end)
end)
