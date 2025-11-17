describe("linter.tclint", function()
  it("can parse tclint output", function()
    local parser = require("lint.linters.tclint").parser
    local result = parser([[
(stdin):1:6: unnecessary command substitution within expression [redundant-expr]
(stdin):2:3: too many positional args for puts: got 5, expected no more than 3 [command-args]
]], 0)

    assert.are.same(2, #result)

    local expected_1 = {
      lnum = 0,
      col = 5,
      end_lnum = 0,
      end_col = 5,
      severity = vim.diagnostic.severity.ERROR,
      source = "tclint",
      message = "unnecessary command substitution within expression",
      code = "redundant-expr",
      user_data = {
        lsp = {
          code = "redundant-expr",
        },
      },
    }

    assert.are.same(expected_1, result[1])

    local expected_2 = {
      lnum = 1,
      col = 2,
      end_lnum = 1,
      end_col = 2,
      severity = vim.diagnostic.severity.ERROR,
      source = "tclint",
      message = "too many positional args for puts: got 5, expected no more than 3",
      code = "command-args",
      user_data = {
        lsp = {
          code = "command-args",
        },
      },
    }

    assert.are.same(expected_2, result[2])
  end)

  it("handles empty output", function()
    local parser = require("lint.linters.tclint").parser
    local result = parser("", 0)
    assert.are.same(0, #result)
  end)
end)
