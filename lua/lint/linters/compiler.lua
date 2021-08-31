local api = vim.api


return function()
  local ok, errorformat = pcall(api.nvim_buf_get_option, 0, 'errorformat')
  if not ok then
    errorformat = vim.o.errorformat
  end
  local makeprg
  ok, makeprg = pcall(api.nvim_buf_get_option, 0, 'makeprg')
  if not ok then
    makeprg = vim.o.makeprg
  end
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
