describe("linter.nilaway", function()
  local scenarios = {
    { "no errors", "{}", {} },
    { "it's empty", "{}", {} },
    { "it's an invalid json", "{", {} },
    {
      "it has a single error",
      '{"command-line-arguments":{"nilaway":[{"posn":"/home/main.go:130:11","message":"Spooky message"}]}}',
      { { lnum = 129, col = 10, message = "Spooky message", severity = 2 } }
    },
    {
      "it has multiple errors",
      '{"command-line-arguments":{"nilaway":[{"posn":"/home/main.go:130:11","message":"Spooky #1"},{"posn":"/home/main.go:131:15","message":"Spooky #2"}]}}',
      {
        { lnum = 129, col = 10, message = "Spooky #1", severity = 2 },
        { lnum = 130, col = 14, message = "Spooky #2", severity = 2 }
      }
    },
    {
      "it has some invalid items",
      '{"command-line-arguments":{"nilaway":[{"posn":"","message":"INVALID"},{"posn":"/home/main.go:131:15","message":"VALID"}]}}',
      {
        { lnum = 130, col = 14, message = "VALID", severity = 2 }
      }
    }
  }

  for _, scenario in ipairs(scenarios) do
    local parser = require('lint.linters.nilaway').parser
    local title, output, expected = unpack(scenario)

    it('can parse the output given ' .. title, function()
      local result = parser(output)
      assert.are.same(result, expected)
    end)
  end
end)
