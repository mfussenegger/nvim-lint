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
      lnum = 258,
      col = 7,
      end_lnum = 258,
      end_col = 17,
      severity = vim.diagnostic.severity.INFO,
    }
    assert.are.same(expected_1, result[1])

    local expected_2 = {
      source = 'cspell',
      message = 'Unknown word (noplugin)',
      lnum = 271,
      col = 18,
      end_lnum = 271,
      end_col = 26,
      severity = vim.diagnostic.severity.INFO,
    }
    assert.are.same(expected_2, result[2])

    local expected_3 = {
      source = 'cspell',
      message = 'Unknown word (noplugin)',
      lnum = 277,
      col = 18,
      end_lnum = 277,
      end_col = 26,
      severity = vim.diagnostic.severity.INFO,
    }
    assert.are.same(expected_3, result[3])

    local expected_4 = {
      source = 'cspell',
      message = 'Unknown word (checkstyle)',
      lnum = 320,
      col = 1,
      end_lnum = 320,
      end_col = 11,
      severity = vim.diagnostic.severity.INFO,
    }
    assert.are.same(expected_4, result[4])
  end)
end)
