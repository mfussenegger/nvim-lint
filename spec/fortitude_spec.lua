describe("linter.fortitude", function()
  it("doesn't error on empty output", function()
    local parser = require("lint.linters.fortitude").parser
    local bufnr = vim.api.nvim_get_current_buf()
    parser("", bufnr, "")
    parser("    ", bufnr, "")
  end)

  it("parses output correctly", function()
    local parser = require("lint.linters.fortitude").parser
    local bufnr = vim.api.nvim_get_current_buf()

    local test_data = [[
[
  {
    "code": "C003",
    "end_location": {
      "column": 18,
      "row": 3
    },
    "filename": "/home/user/documents/somefortranfile.f90",
    "fix": {
      "applicability": "unsafe",
      "edits": [
        {
          "content": " (type, external)",
          "end_location": {
            "column": 18,
            "row": 3
          },
          "location": {
            "column": 18,
            "row": 3
          }
        }
      ],
      "message": "Add `(external)` to 'implicit none'"
    },
    "location": {
      "column": 5,
      "row": 3
    },
    "message": "'implicit none' missing 'external'"
  },
  {
    "code": "E001",
    "end_location": {
      "column": 14,
      "row": 7
    },
    "filename": "/home/user/documents/somefortranfile.f90",
    "fix": null,
    "location": {
      "column": 13,
      "row": 7
    },
    "message": "Syntax error"
  }
]
]]

    local result = parser(test_data, bufnr, "")

    local expected = {
      {
        bufnr = bufnr,
        code = "C003",
        col = 4,
        end_col = 17,
        end_lnum = 2,
        lnum = 2,
        message = "'implicit none' missing 'external'",
        severity = 2,
        source = "fortitude",
      },
      {
        bufnr = bufnr,
        code = "E001",
        col = 12,
        end_col = 13,
        end_lnum = 6,
        lnum = 6,
        message = "Syntax error",
        severity = 1,
        source = "fortitude",
      },
    }

    assert.are.same(expected, result)
  end)
end)
