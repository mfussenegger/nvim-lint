describe("linter.csharpier", function()
  it("can parse the output of an unformatted file", function()
    local parser = require("lint.linters.csharpier").parser
    local result = parser([[
Error ./Bad.cs - Was not formatted.
  ----------------------------- Expected: Around Line 7 -----------------------------
      {
          var x = 1;
      }
  ----------------------------- Actual: Around Line 7 -----------------------------
      {
          var x=1;
      }
]])
    assert.are.same(1, #result)
    local expected = {
      source = "csharpier",
      message = "Replace by:\n    {\n        var x = 1;\n    }",
      lnum = 6,
      col = 0,
      severity = vim.diagnostic.severity.WARN,
    }
    assert.are.same(expected, result[1])
  end)

  it("returns no diagnostics for a formatted file", function()
    local parser = require("lint.linters.csharpier").parser
    local result = parser("Checked 1 files in 100ms.\n")
    assert.are.same({}, result)
  end)
end)
