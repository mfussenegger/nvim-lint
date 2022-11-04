describe('linter.oelint-adv', function()
  it('can parse the output', function()
    local parser = require('lint.linters.oelint-adv').parser
    local bufnr = vim.uri_to_bufnr('file:///foo.bb')
    local result = parser([[
/foo.bb:1:error:oelint.var.mandatoryvar.HOMEPAGE:Variable 'HOMEPAGE' should be set
/foo.bb:1:info:oelint.var.suggestedvar.CVE_PRODUCT:Variable 'CVE_PRODUCT' should be set
/foo.bb:2:warning:oelint.vars.spacesassignment:Suggest spaces around variable assignment. E.g. 'FOO = "BAR"'
]], bufnr)

  assert.are.same(3, #result)

  local expected_error = {
    code = 'oelint.var.mandatoryvar.HOMEPAGE',
    source = 'oelint-adv',
    message = 'Variable \'HOMEPAGE\' should be set',
    lnum = 0,
    col = 0,
    end_lnum = 0,
    end_col = 0,
    severity = vim.diagnostic.severity.ERROR,
    user_data = { lsp = { code = 'oelint.var.mandatoryvar.HOMEPAGE' } },
  }
  assert.are.same(expected_error, result[1])

  local expected_info = {
    code = 'oelint.var.suggestedvar.CVE_PRODUCT',
    source = 'oelint-adv',
    message = 'Variable \'CVE_PRODUCT\' should be set',
    lnum = 0,
    col = 0,
    end_lnum = 0,
    end_col = 0,
    severity = vim.diagnostic.severity.INFO,
    user_data = { lsp = { code = 'oelint.var.suggestedvar.CVE_PRODUCT' } },
  }
  assert.are.same(expected_info, result[2])

  local expected_warning = {
    code = 'oelint.vars.spacesassignment',
    source = 'oelint-adv',
    message = 'Suggest spaces around variable assignment. E.g. \'FOO = "BAR"\'',
    lnum = 1,
    col = 0,
    end_lnum = 1,
    end_col = 0,
    severity = vim.diagnostic.severity.WARN,
    user_data = { lsp = { code = 'oelint.vars.spacesassignment' } },
  }
  assert.are.same(expected_warning, result[3])

  end)
end)
