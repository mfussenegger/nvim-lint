describe("hledger", function()
  local parser = require("lint.linters.hledger").parser
  it("no diagnostics on empty output", function()
    assert.are.same({}, parser(""))
  end)

  it("returns error diagnostic on error output", function()
    -- editorconfig-checker-disable
    local msg = [[
   | 2024-08-10 * payment
   |     revenue:dev:customer          -1.234,00 EUR
14 |     assets:receivable:customer     1.234,00 EUR
   |     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Strict account checking is enabled, and
account "assets:receivable:customer" has not been declared.
Consider adding an account directive. Examples:

account assets:receivable:customer
account assets:receivable:customer    ; type:A  ; (L,E,R,X,C,V)
]]
    -- editorconfig-checker-enable
    local output = "hledger: Error: -:14:" .. msg
    local expected = {
      {
        message = msg,
        col = 0,
        lnum = 13,
        severity = vim.diagnostic.severity.ERROR,
        source = "hledger"
      },
    }
    assert.are.same(expected, parser(output))
  end)
  it("supports column-ranges", function()
    -- editorconfig-checker-disable
    local msg = [[
109 | 2024-08-16 assert balance
    |     assets:checking           4 EUR = 68,59 EUR

This transaction is unbalanced.
The real postings' sum should be 0 but is: 4 EUR
Consider adjusting this entry's amounts, or adding missing postings.
]]
    -- editorconfig-checker-enable
    local output = "hledger: Error: -:109-110:" .. msg
    local expected = {
      {
        message = msg,
        col = 0,
        lnum = 108,
        end_lnum = 109,
        severity = vim.diagnostic.severity.ERROR,
        source = "hledger"
      },
    }
    assert.are.same(expected, parser(output))
  end)
end)
