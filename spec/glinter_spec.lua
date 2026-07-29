describe('linter.glinter', function()
  it('can parse glinter output', function()
    local parser = require('lint.linters.glinter').parser
    local bufnr = vim.uri_to_bufnr("file:///src/application/cells.gleam")

    local result = parser([[
    {
        "results": [
          {
            "rule": "missing_type_annotation",
            "severity": "warning",
            "file": "src/application/cells.gleam",
            "line": 17,
            "message": "Function 'update_cell' is missing a return type annotation"
          }
        ],
        "summary": {
          "total": 1,
          "errors": 0,
          "warnings": 1
        }
      }
    ]], bufnr)

    local expected_warning = {
      lnum = 16,
      end_lnum = 16,
      message = "Function 'update_cell' is missing a return type annotation",
      code = "missing_type_annotation",
      severity = 2,
      source = 'glinter'
    }

    assert.are.same(result[1], expected_warning)
  end)
end)
