describe('linter.cppcheck', function()
  it('can parse the output', function()
    local parser = require('lint.linters.cppcheck').parser
    local bufnr = vim.uri_to_bufnr('file:///foo.cpp')
    local result = parser([[
/foo.cpp:46:7: [unusedVariable] style: Unused variable: fd
/foo.cpp:366:3: [postfixOperator] performance: Prefer prefix ++/-- operators for non-primitive types.
/foo.cpp:46:{column}: [unusedVariable] style: Unused variable: fd
/foo.cpp:366:{column}: [postfixOperator] performance: Prefer prefix ++/-- operators for non-primitive types.
]], bufnr)

  assert.are.same(4, #result)

  local expected_1_88 = {
    code = 'unusedVariable',
    source = 'cppcheck',
    message = 'Unused variable: fd',
    lnum = 45,
    col = 6,
    end_lnum = 45,
    end_col = 6,
    severity = vim.diagnostic.severity.INFO,
    user_data = { lsp = { code = 'unusedVariable' } },
  }
  assert.are.same(expected_1_88, result[1])

  local expected_1_34 = {
    code = 'unusedVariable',
    source = 'cppcheck',
    user_data = { lsp = { code = 'unusedVariable' } },
    message = 'Unused variable: fd',
    lnum = 45,
    col = 0,
    end_lnum = 45,
    end_col = 0,
    severity = vim.diagnostic.severity.INFO,
  }
  assert.are.same(expected_1_34, result[3])

  end)
end)
