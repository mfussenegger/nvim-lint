local pattern = '(.*):(%d+):(%d+) (.*)'
local groups  = { '_', 'line', 'start_col', 'message'}
return {
    cmd = 'markdownlint',
    ignore_exitcode = true,
    stream = 'stderr',
    parser =  require('lint.parser').from_pattern(pattern, groups, nil, {
        ['source'] = 'markdownlint',
        ['severity'] = vim.lsp.protocol.DiagnosticSeverity.Warning,
    })
}
