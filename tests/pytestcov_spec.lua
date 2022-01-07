local output_str = [[
---------- coverage: platform linux, python 3.8.10-final-0 -----------
Name                            Stmts   Miss  Cover   Missing
--------------------------------------------------------------------------
one.py                             0      0     0%   3-104
two.py                             52     9    83%   99-103, 111-114, 124
three.py                           0      0   100%
]]

local errors_launching_tests = [[
---------- coverage: platform linux, python 3.8.10-final-0 -----------
Name                            Stmts   Miss  Cover   Missing
--------------------------------------------------------------------------
one.py                             0      0     0%   3-104
two.py                             52     9    83%   99-103, 111-114, 124
three.py                           0      0   100%

============================================================================================= short test summary info =============================================================================================
ERROR  - ModuleNotFoundError: No module named 'hypothesis'
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Interrupted: 1 error during collection !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
]]

describe('linter.pytestcov', function()
  it('can parse pytestcov output', function()
    local parser = require('lint.linters.pytestcov').parser
    local bufnr_1 = vim.uri_to_bufnr('file:///home/repo/one.py')
    local result_1 = parser(output_str, bufnr_1)
    local expected_1 = {{
      source = 'pytest-cov',
      lnum = 0,
      col = 0,
      severity = vim.diagnostic.severity.INFO,
      message = 'No test coverage was found for this file',
    }}

    assert.are.same(expected_1, result_1)

    local bufnr_2 = vim.uri_to_bufnr('file:///home/repo/two.py')
    local result_2 = parser(output_str, bufnr_2)
    local expected_2 = {
    {
      source = 'pytest-cov',
      lnum = 98,
      col = 0,
      end_lnum = 103,
      severity = vim.diagnostic.severity.INFO,
      message = 'No test coverage found for these lines (until line 103)',
    },
    {
      source = 'pytest-cov',
      lnum = 110,
      col = 0,
      end_lnum = 114,
      severity = vim.diagnostic.severity.INFO,
      message = 'No test coverage found for these lines (until line 114)',
    },
    {
      source = 'pytest-cov',
      lnum = 123,
      col = 0,
      end_lnum = 124,
      severity = vim.diagnostic.severity.INFO,
      message = 'No test coverage found for this line',
    }}

    assert.are.same(expected_2, result_2)

    local bufnr_3 = vim.uri_to_bufnr('file:///home/repo/three.py')
    local result_3 = parser(output_str, bufnr_3)
    local expected_3 = {}

    assert.are.same(expected_3, result_3)

    local bufnr_4 = vim.uri_to_bufnr('file:///home/repo/four.py')
    local result_4 = parser(output_str, bufnr_4)
    local expected_4 = {{
      source = 'pytest-cov',
      lnum = 0,
      col = 0,
      severity = vim.diagnostic.severity.INFO,
      message = 'No test coverage was found for this file',
    }}

    assert.are.same(expected_4, result_4)

    local bufnr_5 = vim.uri_to_bufnr('file:///home/repo/four.py')
    local result_5 = parser(errors_launching_tests, bufnr_5)
    local expected_5 = {{
      source = 'pytest-cov',
      lnum = 0,
      col = 0,
      severity = vim.diagnostic.severity.ERROR,
      message = 'No test coverage analysis could be performed due to errors',
    }}

    assert.are.same(expected_5, result_5)
  end)
end)
