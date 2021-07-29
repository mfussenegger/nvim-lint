describe('from_pattern', function()
  it('Uses source from defaults', function()
    local pattern = '(.*):(%d+):(%d+) (.*)'
    local groups = { '_', 'line', 'start_col', 'message' }
    local defaults = { source = 'test_case' }
    local severity_map = nil
    local parser = require('lint.parser').from_pattern(pattern, groups, severity_map, defaults)
    local output = [[
foo:10:13 Big mistake
bar:209:14 Bigger mistake
]]
    local result = parser(output, 0)
    local expected = {
      {
        message = 'Big mistake',
        range = {
          ['start'] = {
            line = 9,
            character = 12,
          },
          ['end'] = {
            line = 9,
            character = 13,
          }
        },
        severity = vim.lsp.protocol.DiagnosticSeverity.Error,
        source = 'test_case',
      },
      {
        message = 'Bigger mistake',
        range = {
          ['start'] = {
            line = 208,
            character = 13,
          },
          ['end'] = {
            line = 208,
            character = 14,
          }
        },
        severity = vim.lsp.protocol.DiagnosticSeverity.Error,
        source = 'test_case',
      },
    }
    assert.are.same(expected, result)
  end)
end)
