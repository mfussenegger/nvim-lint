describe('linter.j2lint', function()
  it('can parse j2lint output', function()
    local parser = require('lint.linters.j2lint').parser
    local result = parser([[
{
  "ERRORS": [
    {
      "id": "S0",
      "message": "Unexpected end of template. Jinja was looking for the following tags: 'elif' or 'else' or 'endif'. The innermost block that needs to be closed is 'if'.",
      "filename": "/tmp/tmpvks57p9b.j2",
      "line_number": 3,
      "line": "{% for a in b %}{{ a }}{% endfor %}",
      "severity": "HIGH"
    },
    {
      "id": "S7",
      "message": "Jinja statements should be on separate lines, ignoring raw block contents",
      "filename": "/tmp/tmpvks57p9b.j2",
      "line_number": 3,
      "line": "{% for a in b %}{{ a }}{% endfor %}",
      "severity": "MEDIUM"
    },
    {
      "id": "S4",
      "message": "Jinja statement should have at least a single space after '{%' and a single space before '%}'",
      "filename": "/tmp/tmpvks57p9b.j2",
      "line_number": 1,
      "line": "{%if x%}",
      "severity": "LOW"
    }
  ],
  "WARNINGS": [
    {
      "id": "S0",
      "message": "Unexpected end of template.",
      "filename": "/tmp/tmpvks57p9b.j2",
      "line_number": 2,
      "line": "{{ foo}}",
      "severity": "HIGH"
    }
  ]
}
]])
    assert.are.same(4, #result)
    assert.are.same({
      lnum = 2,
      col = 0,
      message = "Unexpected end of template. Jinja was looking for the following tags: 'elif' or 'else' or 'endif'. The innermost block that needs to be closed is 'if'.",
      code = 'S0',
      severity = vim.diagnostic.severity.ERROR,
      source = 'j2lint',
    }, result[1])
    assert.are.same({
      lnum = 2,
      col = 0,
      message = 'Jinja statements should be on separate lines, ignoring raw block contents',
      code = 'S7',
      severity = vim.diagnostic.severity.WARN,
      source = 'j2lint',
    }, result[2])
    assert.are.same({
      lnum = 0,
      col = 0,
      message = "Jinja statement should have at least a single space after '{%' and a single space before '%}'",
      code = 'S4',
      severity = vim.diagnostic.severity.INFO,
      source = 'j2lint',
    }, result[3])
    assert.are.same({
      lnum = 1,
      col = 0,
      message = 'Unexpected end of template.',
      code = 'S0',
      severity = vim.diagnostic.severity.WARN,
      source = 'j2lint',
    }, result[4])
  end)

  it('returns no diagnostics for clean output', function()
    local parser = require('lint.linters.j2lint').parser
    assert.are.same({}, parser('{"ERRORS": [], "WARNINGS": []}'))
    assert.are.same({}, parser(''))
  end)
end)
