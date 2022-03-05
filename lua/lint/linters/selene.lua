local severities = {
  Error = vim.diagnostic.severity.ERROR,
  Warning = vim.diagnostic.severity.WARN,
}

return {
    cmd = "selene",
    stdin = false,
    args = { "--display-style", "json" },
    stream = "stdout",
    ignore_exitcode = true,
    parser = function(output)
        local lines = vim.fn.split(output, "\n")
        local diagnostics = {}
        for _, line in ipairs(lines) do
            local ok, decoded = pcall(vim.json.decode, line)

            if not ok then
                return diagnostics
            end
            local labels = decoded.secondary_labels
            table.insert(labels, decoded.primary_label)

            for _, label in ipairs(labels) do
                local start_offset = label.span.start
                local start_line = vim.fn.byte2line(start_offset)

                local end_offset = label.span["end"]
                local end_line = vim.fn.byte2line(end_offset)

                local message = decoded.message
                if label.message ~= "" then
                    message = message .. ". " .. label.message
                end
                table.insert(diagnostics, {
                    user_data = {
                      lsp = {
                        code = decoded.code,
                        codeDescription = decoded.code,
                      }
                    },
                    code = decoded.code,
                    source = "selene",
                    severity = assert(
                        severities[decoded.severity],
                        "missing mapping for severity " .. decoded.severity
                    ),
                    lnum = start_line - 1,
                    col = start_offset - vim.fn.line2byte(start_line) - 1,
                    end_lnum = end_line - 1,
                    end_col = end_offset - vim.fn.line2byte(end_line) - 1,
                    message = message,
                })
            end
        end
        return diagnostics
    end,
}
