local efm = "%C%[%^^]%#,%E%>Parse error in %f:%l,%E%>Compile error in %f:%l,%-Z%p^%.%#,%C%m,%-G* %.%#"

return {
    cmd = "fennel",
    args = { "--compile" },
    stdin = false,
    ignore_exitcode = true,
    stream = "stderr",
    parser = require("lint.parser").from_errorformat(efm, {
        source = "fennel",
        severity = vim.diagnostic.severity.ERROR,
    }),
}
