describe("linter.deadnix", function()
  it("can parse the output", function()
    local parser = require("lint.linters.deadnix").parser
    local result = parser(
      [[
    {"file":"flake.nix","results":[{"column":17,"endColumn":21,"line":25,"message":"Unused lambda argument: prev"}]}
  ]],
      vim.api.nvim_get_current_buf()
    )
    assert.are.same(1, #result)

    local expected_diagnostics = {
      lnum = 24,
      end_lnum = 24,
      col = 16,
      end_col = 21,
      message = "Unused lambda argument: prev",
      severity = vim.diagnostic.severity.WARN,
    }

    assert.are.same(expected_diagnostics, result[1])
  end)
end)
