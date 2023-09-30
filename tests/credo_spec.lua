describe('linter.credo', function()
  it('can parse the output', function()
    local parser = require('lint.linters.credo').parser
    -- taken from example screenshot from credo's documentation https://hexdocs.pm/credo/overview.html
    -- 3rd record shouldn't get picked up because there is no file/line information
    local result = parser([[
[R] → lib/mix/tasks/my_task.ex:1:11 Unless conditions should avoid having an `else` block.
[W] ↗ lib/my_project.ex:9:5 Use `reraise` inside a rescue block to preserve the original stacktrace.
[W] ↗ Exception modules should be named consistently. It seems your strategy is to have `Error` ....
]], vim.api.nvim_get_current_buf())
    assert.are.same(2, #result)

    local expected_error = {
      col = 10,
      end_col = 10,
      lnum = 0,
      end_lnum = 0,
      severity = 1,
      message = 'Unless conditions should avoid having an `else` block.',
      source = 'credo',
    }

    assert.are.same(expected_error, result[1])

    expected_error = {
      col = 4,
      end_col = 4,
      lnum = 8,
      end_lnum = 8,
      severity = 2,
      message = 'Use `reraise` inside a rescue block to preserve the original stacktrace.',
      source = 'credo',
    }

    assert.are.same(expected_error, result[2])
  end)
end)
