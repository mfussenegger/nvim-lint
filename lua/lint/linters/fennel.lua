local efm = "%C%[%^^]%#,%E%>Parse error in %f:%l,%E%>Compile error in %f:%l,%-Z%p^%.%#,%C%m,%-G* %.%#"

local M

local function globals()
    return table.concat(M.globals, ",")
end

M = {
    cmd = "fennel",
    args = { "--globals", globals, "--compile" },
    stdin = false,
    ignore_exitcode = true,
    stream = "stderr",
    parser = require("lint.parser").from_errorformat(efm, {
        source = "fennel",
        severity = vim.diagnostic.severity.ERROR,
    }),

    -- Users can modify this list like this:
    --  require("lint.linters.fennel").globals = { "foo", "bar" }
    globals = {},
}

return M
