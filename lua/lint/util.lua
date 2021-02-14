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


return M
