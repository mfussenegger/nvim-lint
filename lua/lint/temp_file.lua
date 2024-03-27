local M = {}
--- temp_filepaths associated to their timer (that deletes them)
---@type table<string, uv.uv_timer_t>
local temp_filepath_and_timer = {}
--- count used as index for adding new (path, timer) to temp_filepath_and_timer
local temp_filepath_count = 0

--- close a timer launched by temp_filepath() and clears aucmd associated to temp_filepath
--- replaces using closures in nvim_create_autocmd because the latter is not available in 0.6
--- this function is not meant to be called by users
---@param i integer index internally handled
function M.remove_temp_filepath(path, i)
  os.remove(path)
  -- clear timer
  local timer_r = temp_filepath_and_timer[path]
  temp_filepath_and_timer[path] = nil
  if timer_r:get_due_in() ~= 0 then
    timer_r:stop()
    timer_r:close()
  end
  -- clear all augroup (single aucmd)
  vim.cmd(string.format([[
augroup linttmp%d
  autocmd!
augroup END
  ]], i))
end

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

--- Get a filepath for temporary use.
--- This filepath is deleted on nvim exit or after timeout. If the filepath is not used, the deletion errors silently
---@param opts? table
---@return string filepath to temp file
function M.temp_filepath(opts)
  opts = opts or {}
  local temp_filepath = assert(os.tmpname())
  if opts.ext then
    temp_filepath = temp_filepath .. '.' .. opts.ext
  end

  temp_filepath_count                    = temp_filepath_count + 1
  local temp_filepath_index              = temp_filepath_count

  temp_filepath_and_timer[temp_filepath] = vim.defer_fn(function()
      M.remove_temp_filepath(temp_filepath, temp_filepath_index)
    end,
    opts.timeout or (30 * 1000))

  vim.cmd(string.format([[
augroup linttmp%d
  au VimLeavePre lua require'lint.temp_file'.remove_temp_filepath(%s, %d)
augroup END
  ]],
    temp_filepath_index,
    temp_filepath,
    temp_filepath_index))

  if opts.str then
    local temp_fd = assert(vim.loop.fs_open(temp_filepath, "w", 438))
    assert(vim.loop.fs_write(temp_fd, opts.str))
    assert(vim.loop.fs_close(temp_fd))
  end

  return temp_filepath
end

return M
