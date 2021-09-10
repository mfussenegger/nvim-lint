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
    source = 'cppcheck',
    code = 'unusedVariable',
    message = 'Unused variable: fd',
    range = {
      ['start'] = {
        character = 6,
        line = 45,
      },
      ['end'] = {
        character = 7,
        line = 45,
      }
    },
    severity = vim.lsp.protocol.DiagnosticSeverity.Information,
  }
  assert.are.same(expected_1_88, result[1])

  local expected_1_34 = {
    source = 'cppcheck',
    code = 'unusedVariable',
    message = 'Unused variable: fd',
    range = {
      ['start'] = {
        character = 0,
        line = 45,
      },
      ['end'] = {
        character = 1,
        line = 45,
      }
    },
    severity = vim.lsp.protocol.DiagnosticSeverity.Information,
  }
  assert.are.same(expected_1_34, result[3])

  end)
end)
