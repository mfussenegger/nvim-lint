describe("parser.sarif", function()
  local function fname_to_bufnr(fname)
    return fname == "/home/someuser/Downloads/foo.java" and 1 or 42
  end

  describe("when given the default options", function()
    local parser = require("lint.parser").for_sarif({}, {
      fname_to_bufnr = fname_to_bufnr,
    })

    it("ignores results for different buffers", function()
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

    it("ignores results for unknown levels", function()
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
          "level": "none",
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

      assert.are.same(0, #result)

      assert.are.same({}, result)
    end)

    it("ignores results with present kind other than 'fail'", function()
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
          "kind": "review",
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

      assert.are.same(0, #result)

      assert.are.same({}, result)
    end)

    it("creates diagnostics for all runs", function()
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

    it("creates diagnostics with the correct severity from the results", function()
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
          "level": "error",
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "/home/someuser/Downloads/foo.java"
                },
                "region": {
                  "startColumn": 1,
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
                  "uri": "/home/someuser/Downloads/foo.java"
                },
                "region": {
                  "startColumn": 1,
                  "startLine": 2
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
          "level": "note",
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "/home/someuser/Downloads/foo.java"
                },
                "region": {
                  "startColumn": 1,
                  "startLine": 3
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

      assert.are.same(3, #result)

      assert.are.same({
        bufnr = 1,
        lnum = 0,
        col = 0,
        end_col = 999999,
        severity = vim.diagnostic.severity.ERROR,
        message = "This is a placeholder message.",
        source = "SpecTool",
        code = "placeholder.code",
      }, result[1])

      assert.are.same({
        bufnr = 1,
        lnum = 1,
        col = 0,
        end_col = 999999,
        severity = vim.diagnostic.severity.WARN,
        message = "This is a placeholder message.",
        source = "SpecTool",
        code = "placeholder.code",
      }, result[2])

      assert.are.same({
        bufnr = 1,
        lnum = 2,
        col = 0,
        end_col = 999999,
        severity = vim.diagnostic.severity.INFO,
        message = "This is a placeholder message.",
        source = "SpecTool",
        code = "placeholder.code",
      }, result[3])
    end)

    it("creates diagnostics with the correct severity from default configuration", function()
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
          "name": "SpecTool",
          "rules": [
            {
              "defaultConfiguration": {
                "level": "note"
              }
            },
            {
              "defaultConfiguration": {
                "level": "error"
              }
            },
            {
              "defaultConfiguration": {
                "level": "warning"
              }
            }
          ]
        }
      },
      "results": [
        {
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "/home/someuser/Downloads/foo.java"
                },
                "region": {
                  "startColumn": 1,
                  "startLine": 1
                }
              }
            }
          ],
          "message": {
            "text": "This is a placeholder message."
          },
          "ruleId": "placeholder.code",
          "ruleIndex": 0
        },
        {
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "/home/someuser/Downloads/foo.java"
                },
                "region": {
                  "startColumn": 1,
                  "startLine": 2
                }
              }
            }
          ],
          "message": {
            "text": "This is a placeholder message."
          },
          "ruleId": "placeholder.code",
          "ruleIndex": 1
        },
        {
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "/home/someuser/Downloads/foo.java"
                },
                "region": {
                  "startColumn": 1,
                  "startLine": 3
                }
              }
            }
          ],
          "message": {
            "text": "This is a placeholder message."
          },
          "ruleId": "placeholder.code",
          "ruleIndex": 2
        }
      ]
    }
  ]
}
]],
        1
      )

      assert.are.same(3, #result)

      assert.are.same({
        bufnr = 1,
        lnum = 0,
        col = 0,
        end_col = 999999,
        severity = vim.diagnostic.severity.INFO,
        message = "This is a placeholder message.",
        source = "SpecTool",
        code = "placeholder.code",
      }, result[1])

      assert.are.same({
        bufnr = 1,
        lnum = 1,
        col = 0,
        end_col = 999999,
        severity = vim.diagnostic.severity.ERROR,
        message = "This is a placeholder message.",
        source = "SpecTool",
        code = "placeholder.code",
      }, result[2])

      assert.are.same({
        bufnr = 1,
        lnum = 2,
        col = 0,
        end_col = 999999,
        severity = vim.diagnostic.severity.WARN,
        message = "This is a placeholder message.",
        source = "SpecTool",
        code = "placeholder.code",
      }, result[3])
    end)
  end)

  describe("when given the default_end_col option with '+1'", function()
    local parser = require("lint.parser").for_sarif({}, {
      default_end_col = "+1",
      fname_to_bufnr = fname_to_bufnr,
    })

    it("creates diagnostics without end_col, without endCol", function()
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
end)
