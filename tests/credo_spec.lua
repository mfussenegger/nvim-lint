describe('linter.credo', function()
  it('can parse the output', function()
    local parser = require('lint.linters.credo').parser
    local result = parser([[
Checking 94 source files (this might take a while) ...

  Refactoring opportunities
┃
┃ [F] ↗ Unless conditions should avoid having an `else` block.
┃       lib/fuschia.ex:11:5 #(Fuschia.x)

Please report incorrect results: https://github.com/rrrene/credo/issues

Analysis took 0.3 seconds (0.08s to load, 0.3s running 55 checks on 94 files)
380 mods/funs, found 1 refactoring opportunity.

Use `mix credo explain` to explain issues, `mix credo --help` for options.
      ]])

    assert.are.same(1, #result)

    local expected = {
      source = 'mix credo',
      message = 'Unless conditions should avoid having an `else` block.',
      range = {
        ['start'] = {
          character = 5,
          line = 11
        },
        ['end'] = {
          character = 5,
          line = 11
        }
      },
      severity = vim.lsp.DiagnosticSeveritty.Information
    }

    assert.are.same(expected, result[1])
  end)
end)
