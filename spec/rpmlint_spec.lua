describe('linter.rpmlint', function()
  it('can parse the output', function()
    local parser = require('lint.linters.rpmlint').parser
    local bufnr = vim.uri_to_bufnr('file:///foo.spec')
    local output = [[
warning: line 162: It's not recommended to have unversioned Obsoletes
foo.spec:17: W: %autopatch-not-in-prep
foo.spec: E: specfile-error error: line 31: Unknown tag: %escription
foo.spec:9: E: buildprereq-use Something
]]
    local result = parser(output, bufnr)
    assert.are.same(4, #result)

    local expected_warning_1 = {
      col = 0,
      end_col = 0,
      end_lnum = 161,
      lnum = 161,
      message = "It's not recommended to have unversioned Obsoletes",
      severity = vim.diagnostic.severity.WARN,
      source = 'rpmlint',
    }

    local expected_warning_2 = {
      col = 0,
      end_col = 0,
      end_lnum = 16,
      lnum = 16,
      message = '%autopatch-not-in-prep',
      severity = vim.diagnostic.severity.WARN,
      source = 'rpmlint',
    }

    local expected_error_1 = {
      col = 0,
      end_col = 0,
      end_lnum = 30,
      lnum = 30,
      message = 'Unknown tag: %escription',
      severity = vim.diagnostic.severity.ERROR,
      source = 'rpmlint',
    }

    local expected_error_2 = {
      col = 0,
      end_col = 0,
      end_lnum = 8,
      lnum = 8,
      message = 'buildprereq-use Something',
      severity = vim.diagnostic.severity.ERROR,
      source = 'rpmlint',
    }

    assert.are.same(expected_warning_1, result[1])
    assert.are.same(expected_warning_2, result[2])
    assert.are.same(expected_error_1, result[4])
    assert.are.same(expected_error_2, result[3])
  end)
end)
