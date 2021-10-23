return {
	cmd = "hlint",
	args = { "--json" },
	parser = function(output)
		local diagnostics = {}
		local items = #output > 0 and vim.fn.json_decode(output) or {}
		for _, item in ipairs(items) do
			table.insert(diagnostics, {
				range = {
					["start"] = { line = item.startLine, character = item.startColumn },
					["end"] = { line = item.endLine, character = item.endColumn },
				},
				severity = vim.lsp.protocol.DiagnosticSeverity.Error,
				source = "hlint",
				message = item.hint,
			})
		end
		return diagnostics
	end,
}
