describe("linter.hlint", function()
  it("can parse an error", function()
    -- Main.hs
    --
    -- (first
    --
    -- hlint Main.hs --json
    local parser = require("lint.linters.hlint").parser
    local result = parser([[
      [{"module":[],"decl":[],"severity":"Error","hint":"Parse error: possibly incorrect indentation or mismatched brackets","file":"Main.hs","startLine":2,"startColumn":1,"endLine":2,"endColumn":1,"from":"  (first\n> \n","to":null,"note":[],"refactorings":"[]"}]
    ]])
    assert.are.same(#result, 1)
    local expected = {
      lnum = 2,
      col = 1,
      end_lnum = 2,
      end_col = 1,
      severity = vim.diagnostic.severity.ERROR,
      source = "hlint",
      message = "Parse error: possibly incorrect indentation or mismatched brackets",
    }
    assert.are.same(result[1], expected)
  end)

  it("can parse a warning", function()
    -- Main.hs
    --
    -- concat (map f x)
    --
    -- hlint Main.hs --json
    local parser = require("lint.linters.hlint").parser
    local result = parser([[
      [{"module":["Main"],"decl":[],"severity":"Warning","hint":"Use concatMap","file":"Main.hs","startLine":1,"startColumn":1,"endLine":1,"endColumn":17,"from":"concat (map f x)","to":"concatMap f x","note":[],"refactorings":"[Replace {rtype = Expr, pos = SrcSpan {startLine = 1, startCol = 1, endLine = 1, endCol = 17}, subts = [(\"f\",SrcSpan {startLine = 1, startCol = 13, endLine = 1, endCol = 14}),(\"x\",SrcSpan {startLine = 1, startCol = 15, endLine = 1, endCol = 16})], orig = \"concatMap f x\"}]"}]
    ]])
    assert.are.same(#result, 1)
    local expected = {
      lnum = 1,
      col = 1,
      end_lnum = 1,
      end_col = 17,
      severity = vim.diagnostic.severity.WARN,
      source = "hlint",
      message = "Use concatMap: concatMap f x",
    }
    assert.are.same(result[1], expected)
  end)
end)
