local api = vim.api
describe("codespell", function()
  it("provides end_col", function()
    local parser = require("lint.linters.codespell").parser
    local bufnr = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(bufnr, 0, -1, true, {'  error("hello crate test")'})
    local result = parser("1: crate ==> create", bufnr)
    local expected = {
      {
        col = 15,
        end_col = 20,
        end_lnum = 0,
        lnum = 0,
        message = 'crate ==> create',
        severity = vim.diagnostic.severity.INFO,
        source = 'codespell',
      }
    }
    assert.are.same(expected, result)
  end)
end)
