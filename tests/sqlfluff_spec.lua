describe('linter.sqlfluff', function()
  it('multi-line output from sqlfluff', function()
    local parser = require('lint.linters.sqlfluff').parser
    local bufnr = vim.uri_to_bufnr('file:///non-existent.sql')
    -- actual output I got from running sqlfluff
    local result = parser([[
[{"filepath": "stdin", "violations": [{"line_no": 68, "line_pos": 1, "code": "L003", "description": "Expected 1 indentation, found 0 [compared to line 52]"}, {"line_no": 68, "line_pos": 1, "code": "L013", "description": "Column expression without alias. Use explicit `AS` clause."}]}]

]], bufnr)
    assert.are.same(2, #result)

    local expected = {}
    expected[1] = {
      source = 'sqlfluff',
      message = 'Expected 1 indentation, found 0 [compared to line 52]',
      lnum = 67, -- mind the line indexing
      col = 0, -- mind the column indexing
      severity = vim.diagnostic.severity.ERROR,
      user_data = {lsp = {code = 'L003'}},
    }
    assert.are.same(expected[1], result[1])

    expected[2] = {
      source = 'sqlfluff',
      message = 'Column expression without alias. Use explicit `AS` clause.',
      lnum = 67,
      col = 0,
      severity = vim.diagnostic.severity.ERROR,
      user_data = {lsp = {code = 'L013'}},
    }
    assert.are.same(expected[2], result[2])

  end)
  it("bad CLI args end in non-json output", function()
    local parser = require('lint.linters.sqlfluff').parser
    local bufnr = vim.uri_to_bufnr('file:///non-existent.sql')
    -- when problems are encountered, sqlfluff will report with plain text and
    -- not a formatted json
    local status, _ = pcall(parser, [[
Error: Unknown dialect 'postgresql'
]], bufnr)

    -- not breaking should be enough, the parsing error is reported as "problem in first line-col"
    assert(status)

  end)
end)
