local pattern = '(%d+):(%d+):(%d+):(.+):(%d+):(.*)'
local severities = {
    Error = vim.lsp.protocol.DiagnosticSeverity.Error,
    Warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
    Message = vim.lsp.protocol.DiagnosticSeverity.Information
}

return {
    cmd = 'chktex',
    stdin = true,
    args = {'-v0', '-I0', '-s', ':', '-f', '%l%b%c%b%d%b%k%b%n%b%m%b%b%b'},
    parser = function(output, _)
        local result = vim.fn.split(output, ":::")
        local diagnostics = {}

        for _, line in ipairs(result) do
            local lineno, off, d, sev, code, desc = string.match(line, pattern)

            lineno = tonumber(lineno or 1) - 1
            off = tonumber(off or 1) - 1
            d = tonumber(d or 1)
            table.insert(diagnostics, {
                source = 'chktex',
                range = {
                    ['start'] = {line = lineno, character = off},
                    ['end'] = {line = lineno, character = off + d}
                },
                message = desc,
                severity = assert(severities[sev],
                                  'missing mapping for severity ' .. sev),
                code = code
            })
        end
        return diagnostics

    end
}
