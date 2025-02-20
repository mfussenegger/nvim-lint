describe("linter.graylint", function()
  it("can parse graylint output", function()
    local parser = require("lint.linters.graylint").parser
    local bufnr = vim.uri_to_bufnr("file:///lots_of_errors.py")
    local output = [[
/************* Module lots_of_errors
/lots_of_errors.py:4:0: C0116: Missing function or method docstring (missing-function-docstring)
/lots_of_errors.py:8:11: E0602: Undefined variable 'miles' (undefined-variable)
/lots_of_errors.py:6:4: W0612: Unused variable 'is_same' (unused-variable)
/
/------------------------------------------------------------------
/Your code has been rated at 0.00/10 (previous run: 0.00/10, +0.00)
]]
    local result = parser(output, bufnr)

    assert.are.same(3, #result)

    local expected_1 = {
      source = "graylint",
      message = "Missing function or method docstring (missing-function-docstring)",
      lnum = 3,
      col = 0,
      end_lnum = 3,
      end_col = 0,
      severity = vim.diagnostic.severity.HINT,
      code = "0116",
      user_data = {
        lsp = {
          code = "0116",
        },
      },
    }
    assert.are.same(expected_1, result[1])

    local expected_2 = {
      source = "graylint",
      message = "Undefined variable 'miles' (undefined-variable)",
      lnum = 7,
      col = 11,
      end_lnum = 7,
      end_col = 11,
      severity = vim.diagnostic.severity.ERROR,
      code = "0602",
      user_data = {
        lsp = {
          code = "0602",
        },
      },
    }
    assert.are.same(expected_2, result[2])

    local expected_3 = {
      source = "graylint",
      message = "Unused variable 'is_same' (unused-variable)",
      lnum = 5,
      col = 4,
      end_lnum = 5,
      end_col = 4,
      severity = vim.diagnostic.severity.WARN,
      code = "0612",
      user_data = {
        lsp = {
          code = "0612",
        },
      },
    }
    assert.are.same(expected_3, result[3])
  end)
end)
