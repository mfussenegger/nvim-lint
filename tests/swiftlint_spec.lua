describe("linter.swiftlint", function()
  it("doesn't error on empty output", function()
    local parser = require("lint.linters.swiftlint")().parser
    parser("", vim.api.nvim_get_current_buf())
    parser("  ", vim.api.nvim_get_current_buf())
  end)

  it("can parse the output", function()
    local parser = require("lint.linters.swiftlint")().parser
    local result = parser(
      [[
Linting 'File1.swift' (217/1344)
Linting 'File2.swift' (218/1344)
Linting 'MainViewModel.swift' (219/1344)
/path/to/file/MainViewModel.swift:652:12: warning: File Length Violation: File should contain 500 lines or less: currently contains 652 (file_length)
Linting 'DetailsViewModel.swift.swift' (217/1344)
/path/to/file/DetailsViewModel.swift:12:14: error: Type Body Length Violation: Type body should span 700 lines or less excluding comments and whitespace: currently spans 738 lines (type_body_length)
Linting 'File3.swift' (218/1344)
Linting 'File4.swift' (219/1344)
    ]],
      vim.api.nvim_get_current_buf()
    )
    assert.are.same(2, #result)

    local expected_warning = {
      source = "swiftlint",
      message = "File Length Violation: File should contain 500 lines or less: currently contains 652 (file_length)",
      lnum = 651,
      end_lnum = 651,
      col = 11,
      end_col = 11,
      severity = vim.diagnostic.severity.WARN,
    }
    assert.are.same(expected_warning, result[1])

    local expected_error = {
      source = "swiftlint",
      message = "Type Body Length Violation: Type body should span 700 lines or less excluding comments and whitespace: currently spans 738 lines (type_body_length)",
      lnum = 11,
      end_lnum = 11,
      col = 13,
      end_col = 13,
      severity = vim.diagnostic.severity.ERROR,
    }
    assert.are.same(expected_error, result[2])
  end)
end)
