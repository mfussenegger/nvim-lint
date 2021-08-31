local api = vim.api


return function()
  local errorformat = api.nvim_buf_get_option(0, 'errorformat')
  local makeprg = api.nvim_buf_get_option(0, 'makeprg')
  local bufname = api.nvim_buf_get_name(0)
  local args = {
    api.nvim_get_option('shellcmdflag'),
    makeprg:gsub(' %%', ' ' .. bufname),
  }
  return {
    cmd = vim.opt.shell:get(),
    args = args,
    stdin = false,
    append_fname = false,
    stream = 'both',
    ignore_exitcode = true,
    parser = require('lint.parser').from_errorformat(errorformat)
  }
end
