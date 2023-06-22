local M = {}
local vfn = vim.fn


-- Returns the path leading up to (and including) the given directory, based on
-- the current buffer's file path.
--
-- Example:
--
-- The buffer path is `foo/bar/baz.txt`. When calling this function with the
-- first argument set to `bar`, this function returns `foo/bar`.
function M.find_nearest_directory(directory)
  local filename = vfn.fnameescape(vfn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p'))
  local relative_path = vfn.finddir(directory, filename .. ';')

  if relative_path == '' then
    return ''
  end

  return vfn.fnamemodify(relative_path, ':p')
end


-- Modifies the linter to call linter.cmd via cmd.exe on Windows.
-- This is necessary for some linters called via their .cmd shim.
function M.inject_cmd_exe(linter)
  if vim.fn.has('win32') ~= 1 then
    return linter
  end
  return vim.tbl_extend("force", linter, {
    cmd = "cmd.exe",
    args = { "/C", linter.cmd, unpack(linter.args) },
  })
end


return M
