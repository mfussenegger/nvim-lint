local efm = '%f:%l:%c %m,%f:%l %m'
local is_windows = vim.loop.os_uname().version:match('Windows')
return {
    cmd = is_windows and 'markdownlint.cmd' or 'markdownlint',
    ignore_exitcode = true,
    stream = 'stderr',
    parser =  require('lint.parser').from_errorformat(efm, {
        source = 'markdownlint',
        severity = vim.diagnostic.severity.WARN,
    })
}
