describe('linter.twig-cs-fixer', function()
  it("doesn't error on empty output", function()
    local parser = require('lint.linters.twig-cs-fixer').parser
    local bufnr = vim.api.nvim_get_current_buf()
    parser('', bufnr, '')
    parser('  ', bufnr, '')
  end)

  it('parses github output correctly', function()
    local parser = require('lint.linters.twig-cs-fixer').parser
    local bufnr = vim.uri_to_bufnr('file:///template.html.twig')
    local result = parser([[
::error file=template.html.twig,line=4,col=28::DelimiterSpacing.Before:4:28 -- Expecting 1 whitespace before "}}"; found 0.
::error file=template.html.twig,line=3,col=75::PunctuationSpacing.After:3:75 -- Expecting 0 whitespace after "|"; found 1.
::error file=template.html.twig,line=3,col=75::PunctuationSpacing.Before:3:75 -- Expecting 0 whitespace before "|"; found 1.
]], bufnr, '')
    assert.are.same(3, #result)

    local expected = {
      lnum = 3,
      end_lnum = 3,
      col = 27,
      end_col = 27,
      message = 'Expecting 1 whitespace before "}}"; found 0.',
      code = 'DelimiterSpacing.Before',
      source = 'twig-cs-fixer',
      severity = vim.diagnostic.severity.ERROR,
      user_data = { lsp = { code = 'DelimiterSpacing.Before' } },
    }
    assert.are.same(expected, result[1])

    expected = {
      lnum = 2,
      end_lnum = 2,
      col = 74,
      end_col = 74,
      message = 'Expecting 0 whitespace after "|"; found 1.',
      code = 'PunctuationSpacing.After',
      source = 'twig-cs-fixer',
      severity = vim.diagnostic.severity.ERROR,
      user_data = { lsp = { code = 'PunctuationSpacing.After' } },
    }
    assert.are.same(expected, result[2])

    expected = {
      lnum = 2,
      end_lnum = 2,
      col = 74,
      end_col = 74,
      message = 'Expecting 0 whitespace before "|"; found 1.',
      code = 'PunctuationSpacing.Before',
      source = 'twig-cs-fixer',
      severity = vim.diagnostic.severity.ERROR,
      user_data = { lsp = { code = 'PunctuationSpacing.Before' } },
    }
    assert.are.same(expected, result[3])

  end)

end)
