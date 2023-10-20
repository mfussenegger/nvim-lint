describe("linter.commitlint", function()
  it("can parse the output", function()
    local parser = require("lint.linters.commitlint").parser
    local result = parser([[
⧗   input: foo: commitlint parser
✖   type must be one of [build, chore, ci, docs, feat, fix, perf, refactor, revert, style, test] [type-enum]

✖   found 1 problems, 0 warnings
ⓘ   Get help: https://github.com/conventional-changelog/commitlint/#what-is-commitlint
]])
    assert.are.same(1, #result)
    local expected = {
      source = "commitlint",
      message = "type must be one of [build, chore, ci, docs, feat, fix, perf, refactor, revert, style, test] [type-enum]",
      lnum = 0,
      col = 0,
      severity = vim.diagnostic.severity.ERROR,
    }
    assert.are.same(expected, result[1])
  end)
end)
