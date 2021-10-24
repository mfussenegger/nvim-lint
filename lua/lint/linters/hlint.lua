local severities = {
	error = vim.lsp.protocol.DiagnosticSeverity.Error,
	warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
	suggestion = vim.lsp.protocol.DiagnosticSeverity.Hint,
}

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
				severity = severities[item.severity:lower()],
				source = "hlint",
				message = item.hint,
			})
		end
		return diagnostics
	end,
}
