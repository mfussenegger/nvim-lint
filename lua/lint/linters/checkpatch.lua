-- This favors the version of `checkpatch.pl` supplied by the project
-- to which the file being linted belongs, falling back to a version
-- accessible via `$PATH`.

local uv = vim.loop or vim.uv

local severity_map = {
  ['ERROR'] = vim.diagnostic.severity.ERROR,
  ['WARNING'] = vim.diagnostic.severity.WARN,
  ['CHECK'] = vim.diagnostic.severity.INFO,
}

local checkpatch_ignore = {
  'COMMIT_MESSAGE',
  'MISSING_SIGN_OFF',
  'OBSOLETE',
  'PATCH_PREFIX',
  'SPDX_LICENSE_TAG',
}

local caps_cache = {}

local function get_caps(full_cmd)
  local stat = uv.fs_stat(full_cmd)
  local mtime = stat and stat.mtime.sec or 0
  local cache_key = full_cmd .. ":" .. mtime
  if caps_cache[cache_key] then
    return caps_cache[cache_key]
  end

  local f = io.open(full_cmd, 'rb')
  if not f then return { ignore = false } end
  local content = f:read(32768)
  f:close()
  local caps = {
    ignore = content and content:find('ignore=s', 1, true) ~= nil or false
  }
  caps_cache[cache_key] = caps
  return caps
end

local parser = require('lint.parser').from_pattern(
  '^%-:(%d+): (%a+): (.+)',
  { 'lnum', 'severity', 'message' },
  severity_map,
  { ['source'] = 'checkpatch' },
  { lnum_offset = -3, end_lnum_offset = -3 }
)

---@return lint.Linter
return function()
  local cwd = vim.fn.getcwd()
  local cmd = vim.fs.joinpath(cwd, 'scripts', 'checkpatch.pl')
  if vim.fn.executable(cmd) == 0 then
    cmd = 'checkpatch.pl'
  end

  local full_cmd = vim.fn.exepath(cmd)
  if full_cmd == "" then
    return {
      name = 'checkpatch',
      cmd = 'true',
      stdin = false,
      parser = parser,
    }
  end

  local caps = get_caps(full_cmd)

  return {
    name = 'checkpatch',
    cmd = 'sh',
    stdin = true,
    ignore_exitcode = true,
    args = {
      '-c',
      function()
        local relpath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p:.')
        local args = { '--terse', '--strict', '--no-signoff' }
        if caps.ignore then
          table.insert(args, '--ignore')
          table.insert(args, table.concat(checkpatch_ignore, ','))
        end
        return string.format(
          'diff -u --label /dev/null --label %s /dev/null - | %s %s -',
          vim.fn.shellescape(relpath),
          vim.fn.shellescape(full_cmd),
          table.concat(args, ' ')
        )
      end
    },
    parser = parser,
  }
end
