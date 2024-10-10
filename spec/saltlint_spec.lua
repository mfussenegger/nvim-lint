describe("linter.saltlint", function()
  it("can parse the output", function()
    local parser = require("lint.linters.saltlint").parser
    local result = parser([[
      [
        {
          "id": "903",
          "message": "State 'virt.reverted' is deprecated since SaltStack version '2016.3.0'",
          "filename": "/tmp/tmpybp_b5bk.sls",
          "linenumber": 3,
          "line": "  virt.reverted:",
          "severity": "HIGH"
        },
        {
          "id": "217",
          "message": "\"requires\" looks like a typo. Did you mean \"require\"?",
          "filename": "/tmp/tmpybp_b5bk.sls",
          "linenumber": 9,
          "line": "    - requires: foo",
          "severity": "LOW"
        },
        {
          "id": "201",
          "message": "Trailing whitespace",
          "filename": "/tmp/tmpybp_b5bk.sls",
          "linenumber": 12,
          "line": "  file.create:  ",
          "severity": "INFO"
        },
        {
          "id": "204",
          "message": "Lines should be no longer than 160 chars",
          "filename": "/tmp/tmpybp_b5bk.sls",
          "linenumber": 17,
          "line": "    - name: test_long_line_aaa...",
          "severity": "VERY_LOW"
        }
      ]
    ]])

    -- Count of results
    assert.are.same(4, #result)

    -- JSON diagnostic with HIGH severity
    assert.are.same({
      lnum = 2,
      col = 1,
      severity = vim.diagnostic.severity.ERROR,
      message = "State 'virt.reverted' is deprecated since SaltStack version '2016.3.0'",
      source = "salt-lint",
      code = "903",
    }, result[1])

    -- JSON diagnostic with LOW severity
    assert.are.same({
      lnum = 8,
      col = 1,
      severity = vim.diagnostic.severity.WARN,
      message = '"requires" looks like a typo. Did you mean "require"?',
      source = "salt-lint",
      code = "217",
    }, result[2])

    -- JSON diagnostic with INFO severity
    assert.are.same({
      lnum = 11,
      col = 1,
      severity = vim.diagnostic.severity.INFO,
      message = "Trailing whitespace",
      source = "salt-lint",
      code = "201",
    }, result[3])

    -- JSON diagnostic with VERY_LOW severity
    assert.are.same({
      lnum = 16,
      col = 1,
      severity = vim.diagnostic.severity.WARN,
      message = "Lines should be no longer than 160 chars",
      source = "salt-lint",
      code = "204",
    }, result[4])
  end)
end)
