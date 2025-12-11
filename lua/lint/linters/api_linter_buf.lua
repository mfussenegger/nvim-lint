--- Extension of api-linter leveraging the buf CLI.
---
--- This is a real-world implementation of api-linter, extending the nvim-lint
--- api_linter.lua linter with additional capabilities, so to be able to follow all
--- proto imports. You can read more about the history of how this api_linter_buf
--- came to be here: https://github.com/mfussenegger/nvim-lint/pull/665
---
--- The api-linter needs a descriptor file, containing all protos in the project as
--- well as third-party proto imports.
--- This adaptation of the api_linter.lua, will build the descriptor file for you,
--- using the buf CLI, as this is the most common way to go about this problem as
--- of writing this. Please see the custom argument function `descriptor_set_in` in
--- this file for more details on how it's done.
---
--- The api-linter needs to be run in the same directory as the buf.yaml. Therefore,
--- the 'cwd' must be set. Unfortunately, you cannot provide the cwd as a function
--- to a linter, which means you will either have to statically set the path or have
--- a function run (which will likely run on nvim-lint load in your Neovim setup,
--- which is undesirable). To work around this, you can instead load api_linter_buf
--- with an autocmd, in which you provide a function for the cwd.
--- I have bundled an example of this in the api_linter_buf `register_autocmd`
--- function, which you can use to register the autocmd:
---   `require("lint.linters.api_linter_buf").register_autocmd()`
--- Please note that this replaces other ways to load this api_linter_buf linter.

local api_linter = require("lint.linters.api_linter")

-- --------------------- api_linter_buf helper functions ---------------------

--- Cached filepath to buf.yaml, so to avoid searching multiple times for it.
local cached_buf_config_filepath = nil

--- Find a file by searching upwards through parent directories.
local function find_file_upwards(names, start_path, stop_path)
  -- Normalize paths
  start_path = vim.fn.fnamemodify(start_path, ":p")
  stop_path = vim.fn.fnamemodify(stop_path, ":p")

  local current_dir = start_path
  while current_dir >= stop_path do
    for _, name in ipairs(names) do
      local file_path = current_dir .. "/" .. name
      if vim.fn.filereadable(file_path) == 1 then
        return file_path
      end
    end
    -- Go up one directory
    local parent_dir = vim.fn.fnamemodify(current_dir, ":h")
    if parent_dir == current_dir then
      break
    end
    current_dir = parent_dir
  end
  return nil
end

-- --------------------- Descriptor file helper functions ---------------------

local descriptor_filepath = os.tmpname()

--- Function to set the `--descriptor-set-in` argument.
--- This requires the buf CLI, which will first build the descriptor file.
local function descriptor_set_in()
  if vim.fn.executable("buf") == 0 then
    error("buf CLI not found")
  end

  local buffer_parent_dir = vim.fn.expand("%:p:h")
  local buf_config_filepath = find_file_upwards({ "buf.yaml", "buf.yml" }, buffer_parent_dir, vim.fn.expand("~"))
    or find_file_upwards("buf.yml", buffer_parent_dir)

  if not buf_config_filepath then
    error("Buf config file not found")
  end

  -- build the descriptor file.
  local buf_config_folderpath = vim.fn.fnamemodify(buf_config_filepath, ":h")
  local buf_cmd = string.format(
    "cd %s && buf build -o %s",
    vim.fn.shellescape(buf_config_folderpath),
    vim.fn.shellescape(descriptor_filepath)
  )
  local output = vim.fn.system(buf_cmd)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 then
    error("Command failed: " .. buf_cmd .. "\n" .. output)
  end

  -- return the argument to be passed to the linter.
  return "--descriptor-set-in=" .. descriptor_filepath
end

local cleanup_descriptor = function()
  os.remove(descriptor_filepath)
end

-- --------------------- Autocmd example ---------------------

--- Autocmd which will load the linter, due to no cwd-as-function support.
--- HACK: more info: https://github.com/mfussenegger/nvim-lint/pull/674
local function autocmd(cwd)
  --- Find buf.yaml.
  local function get_buf_config_filepath()
    if cached_buf_config_filepath ~= nil then
      return cached_buf_config_filepath
    end
    local buffer_parent_dir = vim.fn.expand("%:p:h")
    local buf_config_filepath = find_file_upwards({ "buf.yaml", "buf.yml" }, buffer_parent_dir, vim.fn.expand("~"))
    if not buf_config_filepath then
      error("Buf config file not found")
    end
    cached_buf_config_filepath = buf_config_filepath
    vim.notify("buf config file found: " .. cached_buf_config_filepath)
    return cached_buf_config_filepath
  end

  local function buf_lint_cwd()
    return vim.fn.fnamemodify(get_buf_config_filepath(), ":h")
  end

  if cwd == nil then
    cwd = buf_lint_cwd
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = { "*.proto" },
    callback = function()
      require("lint").try_lint("api_linter", {
        cwd = cwd(),
      })
    end,
  })
end

-- --------------------- api_linter_buf configuration ---------------------

local function build_args()
  local args = {}
  -- Copy all args except the last one (which is the filename function)
  for i = 1, #api_linter.args - 1 do
    table.insert(args, api_linter.args[i])
  end
  -- Insert descriptor_set_in before the filename
  table.insert(args, descriptor_set_in)
  -- Add the filename function last
  table.insert(args, api_linter.args[#api_linter.args])
  return args
end

return {
  cmd = api_linter.cmd,
  stdin = api_linter.stdin,
  append_fname = api_linter.append_fname,
  args = build_args(),
  stream = api_linter.stream,
  ignore_exitcode = api_linter.ignore_exitcode,
  env = api_linter.env,
  parser = function(output)
    local diagnostics = api_linter.parser(output)
    cleanup_descriptor()
    return diagnostics
  end,

  register_autocmd = autocmd,
}
