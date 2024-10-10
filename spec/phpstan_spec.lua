local bufnr = vim.uri_to_bufnr('file:///test.php')

describe('linter.phpstan', function()
  it("doesn't error on empty output", function()
    local parser = require('lint.linters.phpstan').parser
    parser('')
    parser('  ')
  end)

  it('parses json output correctly', function()
    local parser = require('lint.linters.phpstan').parser
    local result = parser(
      [[
  {
    "totals": {
      "errors": 0,
      "file_errors": 2
    },
    "files": {
      "/test.php": {
        "errors": 2,
        "messages": [
          {
            "message": "Ignored error pattern",
            "line": null,
            "ignorable": false
          },
          {
            "message": "Property never read, only written.",
            "line": 6,
            "ignorable": true,
            "tip": "See: https://phpstan.org/developing-extensions/always-read-written-properties"
          }
        ]
      }
    },
    "errors": []
  }
      ]],
      bufnr
    )

    local expected = {
      {
        col = 0,
        lnum = 0,
        message = 'Ignored error pattern',
        source = 'phpstan',
      },
      {
        col = 0,
        lnum = 5,
        message = 'Property never read, only written.',
        source = 'phpstan',
      },
    }

    assert.are.same(expected, result)
  end)
end)
