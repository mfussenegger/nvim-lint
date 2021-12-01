describe('from_errorformat', function()
  it('Parses single-line errorformat', function()
    local efm = '%f:%l:%c:%t:%n:%m'
    local skeleton = { source = 'test_case' }
    local parser = require('lint.parser').from_errorformat(efm, skeleton)
    local output = [[
dir1/file1.txt:10:15:E:200:Big mistake
dir2/file2.txt:20:25:W:300:Bigger mistake
]]
    local result = parser(output)
    local expected = {
      {
        message = 'Big mistake',
        range = {
          ['start'] = {
            line = 9,
            character = 14,
          },
          ['end'] = {
            line = 9,
            character = 14,
          }
        },
        severity = vim.lsp.protocol.DiagnosticSeverity.Error,
        source = 'test_case',
      },
      {
        message = 'Bigger mistake',
        range = {
          ['start'] = {
            line = 19,
            character = 24,
          },
          ['end'] = {
            line = 19,
            character = 24,
          }
        },
        severity = vim.lsp.protocol.DiagnosticSeverity.Warning,
        source = 'test_case',
      },
    }
    assert.are.same(expected, result)
  end)

  it('Strips newlines and whitespace from error message', function()
    -- NOTE: %m on subsequent line of multi-line emf will include a starting
    -- newline character
    local parser = require('lint.parser').from_errorformat('%W%l,%Z%m')
    assert.equals('Big Mistake', parser('10\n \t Big Mistake \t \n')[1].message)
  end)
end)

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
