local severities = {
  Error = vim.diagnostic.severity.ERROR,
  Warning = vim.diagnostic.severity.WARN,
}

return {
    cmd = "selene",
    stdin = true,
    args = { "--display-style", "json", "-" },
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
                    lnum = label.span.start_line,
                    col = label.span.start_column,
                    end_lnum = label.span.end_line,
                    end_col = label.span.end_column,
                    message = message,
                })
            end
        end
        return diagnostics
    end,
}
