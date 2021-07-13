local severities = {
    W = vim.lsp.protocol.DiagnosticSeverity.Warning,
    E = vim.lsp.protocol.DiagnosticSeverity.Error
}

local pattern = '[^:]+:(%d+):(%d+)-(%d+): %((%a)(%d+)%) (.*)'

return {
    cmd = 'luacheck',
    stdin = true,
    args = {'--formatter', 'plain', '--codes', '--ranges', '-'},
    ignore_exitcode = true,
    parser = function(output, _)
        local result = vim.fn.split(output, "\n")
        local diagnostics = {}

        for _, message in ipairs(result) do
            local line, offs, offe, severity, code, desc =
                string.match(message, pattern)

            line = tonumber(line or 1) - 1
            offs = tonumber(offs or 1) - 1
            offe = tonumber(offe or 1)

            table.insert(diagnostics, {
                source = 'luacheck',
                range = {
                    ['start'] = {line = line, character = offs},
                    ['end'] = {line = line, character = offe}
                },
                message = desc,
                severity = assert(severities[severity],
                                  'missing mapping for severity ' .. severity),
                code = code
            })
        end

        return diagnostics
    end
}

