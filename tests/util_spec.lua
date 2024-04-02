describe("lint.util", function()
  local util = require("lint.util")
  it("wrap can re-map diagnostics from lint result", function()
    local cspell = require("lint.linters.cspell")
    local custom_cspell = util.wrap(cspell, function(diagnostic)
      diagnostic.severity = vim.diagnostic.severity.HINT
      return diagnostic
    end)
    local output = [[
/:259:8 - Unknown word (langserver)
/:272:19 - Unknown word (noplugin)
]]

    local bufnr = vim.uri_to_bufnr('file:///foo.txt')
    local orig_result = cspell.parser(output, bufnr)
    local result = custom_cspell.parser(output, bufnr)
    assert.are.same(#result, 2)
    assert.are.same(#orig_result, 2)
    assert.are.same(result[1].severity, vim.diagnostic.severity.HINT)
    assert.are.same(orig_result[1].severity, vim.diagnostic.severity.INFO)
  end)
end)
