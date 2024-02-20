describe('linter.systemdlint', function()
  it('can parse the output', function()
    local parser = require('lint.linters.systemdlint').parser
    local bufnr = vim.uri_to_bufnr('file:///foo.service')
    local result = parser([[
/foo.service:1:error:ExecNotFound:Command referenced not found
/foo.service:2:info:NoFailureCheck:Return-code check is disabled. Errors are not reported
/foo.service:3:warning:ReferencedUnitNotFound:The Unit 'bar.service' referenced was not found in filesystem
]], bufnr)

  assert.are.same(3, #result)

  local expected_error = {
    code = 'ExecNotFound',
    source = 'systemdlint',
    message = 'Command referenced not found',
    lnum = 0,
    col = 0,
    end_lnum = 0,
    end_col = 0,
    severity = vim.diagnostic.severity.ERROR,
    user_data = { lsp = { code = 'ExecNotFound' } },
  }
  assert.are.same(expected_error, result[1])

  local expected_info = {
    code = 'NoFailureCheck',
    source = 'systemdlint',
    message = 'Return-code check is disabled. Errors are not reported',
    lnum = 1,
    col = 0,
    end_lnum = 1,
    end_col = 0,
    severity = vim.diagnostic.severity.INFO,
    user_data = { lsp = { code = 'NoFailureCheck' } },
  }
  assert.are.same(expected_info, result[2])

  local expected_warning = {
    code = 'ReferencedUnitNotFound',
    source = 'systemdlint',
    message = 'The Unit \'bar.service\' referenced was not found in filesystem',
    lnum = 2,
    col = 0,
    end_lnum = 2,
    end_col = 0,
    severity = vim.diagnostic.severity.WARN,
    user_data = { lsp = { code = 'ReferencedUnitNotFound' } },
  }
  assert.are.same(expected_warning, result[3])

  end)
end)
