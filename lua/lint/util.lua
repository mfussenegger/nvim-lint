local M = {}


function M.offset_to_position(lines, offset)
  local remainder = offset
  local lnum = 0
  local character = 0
  for i, line in pairs(lines) do
    local new_remainder = remainder - #line
    if new_remainder < 0 then
      character = remainder
      lnum = i - 1
      break
    else
      remainder = new_remainder
    end
  end
  return {
    line = lnum,
    character = character,
  }
end

-- Returns the path leading up to (and including) the given directory, based on
-- the current buffer's file path.
--
-- Example:
--
-- The buffer path is `foo/bar/baz.txt`. When calling this function with the
-- first argument set to `bar`, this function returns `foo/bar`.
function M.find_nearest_directory(directory)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p')
  local filename = vim.fn.fnameescape(filename)
  local relative_path = vim.fn.finddir(directory, filename .. ';')

  if relative_path == '' then
    return ''
  end

  return vim.fn.fnamemodify(relative_path, ':p')
end


return M
