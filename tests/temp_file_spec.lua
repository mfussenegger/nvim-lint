local function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

describe('temp_file', function()
  it('Creates temp file', function()
    local temp_file = require 'lint.temp_file'
    local temp_filepath = temp_file.temp_filepath()
    assert.are.not_equal(temp_filepath, "")
  end)

  it('Creates temp file with extension', function()
    local temp_file = require 'lint.temp_file'
    local temp_filepath = temp_file.temp_filepath({ ext = 'some_ext' })

    assert.is_truthy(vim.endswith(temp_filepath, '.some_ext'))
  end)

  it('Creates temp file with str', function()
    local temp_file = require 'lint.temp_file'
    local temp_filepath = temp_file.temp_filepath({ str = 'some text' })

    local text = ""
    for line in io.lines(temp_filepath) do
      text = string.format("%s%s", text, line)
    end
    assert.are.equal(text, 'some text')
  end)


  it('File is deleted after specified timeout', function()
    local temp_file = require 'lint.temp_file'
    local temp_filepath = temp_file.temp_filepath({ timeout = 50, str = 'some text' })

    assert.is_true(file_exists(temp_filepath))

    vim.wait(100, function() end) -- file should be deleted after this

    assert.is_false(file_exists(temp_filepath))
  end

  )
end)
