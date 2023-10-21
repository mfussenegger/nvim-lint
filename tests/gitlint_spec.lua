describe("linter.gitlint", function()
  it("can parse the output", function()
    local parser = require("lint.linters.gitlint").parser
    local bufnr = vim.uri_to_bufnr("file:///COMMIT_MSG")
    local result = parser([[3: B5 Body message is too short (11<20): "foo bar baz"]], bufnr)
    local expected = {
      source = "gitlint",
      message = "Body message is too short",
      code = "B5",
      lnum = 2,
      end_lnum = 2,
      col = 0,
      severity = vim.diagnostic.severity.INFO,
    }
    assert.are.same(expected, result)
  end)
end)
