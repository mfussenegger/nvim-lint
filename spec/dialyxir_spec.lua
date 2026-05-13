describe("linter.dialyxir", function()
  it("can parse the output", function()
    local parser = require("lint.linters.dialyxir").parser
    local bufnr = vim.uri_to_bufnr("file:///foo.ex")
    local result = parser( [[
::warning file=foo.ex,line=16,col=11,title=unmatched_return::The expression produces multiple types, but none are matched.
::warning file=foo.ex,line=28,title=invalid_contract::Invalid type specification for function should_fail.
]], bufnr)
    assert.are.same(2, #result)

    -- -1 because rows and columns from 'mix dialyzer' are 1-based

    local expected_error = {
      col = 11 - 1,
      lnum = 16 - 1,
      severity = 2,
      message = "The expression produces multiple types, but none are matched.",
      source = "dialyzer",
      bufnr = bufnr,
    }

    assert.are.same(expected_error, result[1])

    expected_error = {
      col = 0,
      lnum = 28 - 1,
      severity = 2,
      message = "Invalid type specification for function should_fail.",
      source = "dialyzer",
      bufnr = bufnr,
    }

    assert.are.same(expected_error, result[2])
  end)
end)
