describe('linter.cspell', function()
  it('can parse cspell output', function()
    local parser = require('lint.linters.cspell').parser
    local bufnr = vim.uri_to_bufnr('file:///foo.txt')
    local result = parser([[
/:259:8 - Unknown word (langserver)
/:272:19 - Unknown word (noplugin)
/:278:19 - Unknown word (noplugin)
/:321:2 - Unknown word (checkstyle)
]], bufnr)

    assert.are.same(4, #result)

    local expected_1 = {
      source = 'cspell',
      message = 'Unknown word (langserver)',
      range = {
        ['start'] = {
          character = 7,
          line = 258
        },
        ['end'] = {
          character = 7,
          line = 258
        }
      },
      severity = vim.lsp.protocol.DiagnosticSeverity.Information,
    }
    assert.are.same(expected_1, result[1])

    local expected_2 = {
      source = 'cspell',
      message = 'Unknown word (noplugin)',
      range = {
        ['start'] = {
          character = 18,
          line = 271
        },
        ['end'] = {
          character = 18,
          line = 271
        }
      },
      severity = vim.lsp.protocol.DiagnosticSeverity.Information,
    }
    assert.are.same(expected_2, result[2])

    local expected_3 = {
      source = 'cspell',
      message = 'Unknown word (noplugin)',
      range = {
        ['start'] = {
          character = 18,
          line = 277
        },
        ['end'] = {
          character = 18,
          line = 277
        }
      },
      severity = vim.lsp.protocol.DiagnosticSeverity.Information,
    }
    assert.are.same(expected_3, result[3])

    local expected_4 = {
      source = 'cspell',
      message = 'Unknown word (checkstyle)',
      range = {
        ['start'] = {
          character = 1,
          line = 320
        },
        ['end'] = {
          character = 1,
          line = 320
        }
      },
      severity = vim.lsp.protocol.DiagnosticSeverity.Information,
    }
    assert.are.same(expected_4, result[4])
  end)
end)
