local M = {}

---@class lint.temp_file.Opts
---@inlinedoc
---
--- Extension for the filepath
---@field ext? string
---
--- Timeout in ms to delete the file (defaults to 30_000 = 30s)
---@field timeout? number
---
--- Text to be inserted into file
---@field str? string

--- Get a temporary filepath. This filepath is deleted on nvim exit or after timeout
---@param opts? table
---@return string filepath to temp file
function M.temp_filepath(opts)
  opts = opts or {}
  local temp_filepath = assert(os.tmpname())
  if opts.ext then
    temp_filepath = temp_filepath .. '.' .. opts.ext
  end

  local timer_r, vimexit_r

  timer_r = vim.defer_fn(function()
      os.remove(temp_filepath)

      vim.api.nvim_del_autocmd(vimexit_r)
    end,
    opts.timeout or (30 * 1000))

  vimexit_r = vim.api.nvim_create_autocmd("VimLeavePre", {
    pattern = "*",
    once = true,
    callback = function()
      os.remove(temp_filepath)

      if timer_r:get_due_in() ~= 0 then
        timer_r:stop()
        timer_r:close()
      end
    end,
  })
  if opts.str then
    local temp_fd = assert(vim.loop.fs_open(temp_filepath, "w", 438))
    assert(vim.loop.fs_write(temp_fd, opts.str))
    assert(vim.loop.fs_close(temp_fd))
  end

  return temp_filepath
end

return M
