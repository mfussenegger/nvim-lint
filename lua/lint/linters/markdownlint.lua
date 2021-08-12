local efm = '%f:%l:%c %m,%f:%l %m'
return {
    cmd = 'markdownlint',
    ignore_exitcode = true,
    stream = 'stderr',
    parser =  require('lint.parser').from_errorformat(efm, {
        source = 'markdownlint',
        severity = vim.lsp.protocol.DiagnosticSeverity.Warning,
    })
}
