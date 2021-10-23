describe("linter.hlint", function()
	it("can parse the output", function()
		local parser = require("lint.linters.hlint").parser
		local result = parser([[
		[{"module":[],"decl":[],"severity":"Error","hint":"Parse error: possibly incorrect indentation or mismatched brackets","file":"2021-watson/section-1/Main.hs","startLine":3,"startColumn":1,"endLine":3,"endColumn":1,"from":"  main = do\n    putStrLn (\"1 + 2 = \" ++ show (1 + 2)\n> \n","to":null,"note":[],"refactorings":"[]"}]
		]])
		assert.are.same(#result, 1)
		local expected = {
			range = {
				["start"] = {
					character = 1,
					line = 3,
				},
				["end"] = {
					character = 1,
					line = 3,
				},
			},
			severity = vim.lsp.protocol.DiagnosticSeverity.Error,
			source = "hlint",
			message = "Parse error: possibly incorrect indentation or mismatched brackets",
		}
		assert.are.same(result[1], expected)
	end)
end)
