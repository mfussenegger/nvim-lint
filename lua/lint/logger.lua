local M = {}

M.log_levels = {
  error = 1,
  warning = 2,
  info = 3,
  debug = 4,
}

local log_level = M.log_levels.warning

local function write_to_file(message)
  local log_path = vim.fn.stdpath('state') .. '/nvim-lint.log'
  local log_file = io.open(log_path, 'a+')
  if not log_file then
    vim.api.nvim_out_write('[nvim-lint] failed to open log file\n')
    return
  end
  log_file:write(message .. '\n')
  log_file:close()
end

function M.set_log_level(level)
  log_level = M.log_levels[level]
end

local function log(level_name, level, prefix, format, ...)
  if log_level >= level then
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local message = string.format('[%s][%s][%s] ' .. format, timestamp, level_name, prefix, ...)
    write_to_file(message)
  end
end

function M.new(prefix)
  return {
    assert = function(condition, format, ...)
      local arguments = { ... }
      if not condition then
        log('ASSERT', M.log_levels.error, prefix, format or '', ...)
      end
      return assert(condition, arguments[1])
    end,
    error = function(format, ...)
      local arguments = { ... }
      log('ERROR', M.log_levels.error, prefix, format, ...)
      error(arguments[1])
    end,
    warning = function(format, ...)
      log('WARNING', M.log_levels.warning, prefix, format, ...)
    end,
    info = function(format, ...)
      log('INFO', M.log_levels.info, prefix, format, ...)
    end,
    debug = function(format, ...)
      log('DEBUG', M.log_levels.debug, prefix, format, ...)
    end,
    format_diagnostic = function(diagnostic)
      return string.format(
        'lnum=%d col=%d end_lnum=%d end_col=%d severity=%s message=%s code=%s',
        diagnostic.lnum,
        diagnostic.col,
        diagnostic.end_lnum,
        diagnostic.end_col,
        diagnostic.severity,
        diagnostic.message,
        diagnostic.code
      )
    end,
  }
end

function M.open()
  vim.cmd('e ' .. vim.fn.stdpath('state') .. '/nvim-lint.log')
end

return M
