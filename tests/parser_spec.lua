describe('from_errorformat', function()
  it('Parses single-line errorformat', function()
    local efm = '%f:%l:%c:%t:%n:%m'
    local skeleton = { source = 'test_case' }
    local parser = require('lint.parser').from_errorformat(efm, skeleton)
    local output = [[
dir1/file1.txt:10:15:E:200:Big mistake
dir2/file2.txt:20:25:W:300:Bigger mistake
]]
    local result = parser(output, 0, "/")
    local expected = {
      {
        message = 'Big mistake',
        lnum = 9,
        col = 14,
        end_lnum = 9,
        end_col = 14,
        severity = vim.diagnostic.severity.ERROR,
        source = 'test_case',
      },
      {
        message = 'Bigger mistake',
        lnum = 19,
        col = 24,
        end_lnum = 19,
        end_col = 24,
        severity = vim.diagnostic.severity.WARN,
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
    local groups = { '_', 'lnum', 'col', 'message' }
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
        lnum = 9,
        col = 12,
        end_lnum = 9,
        end_col = 12,
        severity = vim.diagnostic.severity.ERROR,
        source = 'test_case',
      },
      {
        message = 'Bigger mistake',
        lnum = 208,
        col = 13,
        end_lnum = 208,
        end_col = 13,
        severity = vim.diagnostic.severity.ERROR,
        source = 'test_case',
      },
    }
    assert.are.same(expected, result)
  end)
end)
