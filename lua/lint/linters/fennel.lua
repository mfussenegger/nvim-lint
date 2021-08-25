local efm = "%EParse error in %f:%l,%ECompile error in %f:%l,%C%*\\s%m,%-C%p^,%-G%.%#"

local M

local function globals()
    return table.concat(M.globals, ",")
end

M = {
    cmd = "fennel",
    args = { "--globals", globals, "--compile" },
    stdin = false,
    ignore_exit_code = true,
    stream = "stderr",
    parser = require("lint.parser").from_errorformat(efm, {
        source = "fennel",
        severity = vim.lsp.protocol.DiagnosticSeverity.Error,
    }),

    -- Users can modify this list like this:
    --  require("lint.linters.fennel").globals = { "foo", "bar" }
    globals = {},
}

return M
