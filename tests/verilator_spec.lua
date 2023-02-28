describe('linter.verilator', function()
  it('can parse the output', function()
    local parser = require('lint.linters.verilator').parser
    local result = parser([[
%Warning-DECLFILENAME: t.v:24:8: Filename 't' does not match MODULE name: 'uart'
    24 | module uart
      |        ^~~~
                        ... For warning description see https://verilator.org/warn/DECLFILENAME?v=5.006
                        ... Use "/* verilator lint_off DECLFILENAME */" and lint_on around source to disable this message.
%Warning-PINCONNECTEMPTY: t.v:48:4: Cell pin connected by name with empty reference: 'wr_rst_busy'
    48 |   .wr_rst_busy(),
      |    ^~~~~~~~~~~
%Warning-PINCONNECTEMPTY: t.v:49:4: Cell pin connected by name with empty reference: 'rd_rst_busy'
    49 |   .rd_rst_busy(),
      |    ^~~~~~~~~~~
%Error: t.v:45:4: Cannot find file containing module: 'tx_fifo'
    45 |    tx_fifo
      |    ^~~~~~~
%Error: t.v:45:4: This may be because there's no search path specified with -I<dir>.
    45 |    tx_fifo
      |    ^~~~~~~
        ... Looked in:
              tx_fifo
              tx_fifo.v
              tx_fifo.sv
              obj_dir/tx_fifo
              obj_dir/tx_fifo.v
              obj_dir/tx_fifo.sv
%Error: t.v:64:2: Cannot find file containing module: 'uart_tx'
    64 |  uart_tx
      |  ^~~~~~~
%Error: Exiting due to 3 error(s), 3 warning(s)
    ]], vim.api.nvim_get_current_buf())
    assert.are.same(6, #result)

    local expected = {
      source = 'verilator',
      message = 'Filename \'t\' does not match MODULE name: \'uart\'',
      severity = vim.diagnostic.severity.WARN,
      lnum = 23,
      col = 7,
      end_lnum = 23,
      end_col = 7,
      code = 'DECLFILENAME',
      user_data = {
        lsp = {
          code = 'DECLFILENAME',
        }
      },
    }
    assert.are.same(expected, result[1])

    expected = {
      source = 'verilator',
      message = 'This may be because there\'s no search path specified with -I<dir>.',
      severity = vim.diagnostic.severity.ERROR,
      lnum = 44,
      col = 3,
      end_lnum = 44,
      end_col = 3,
      code = '',
      user_data = {
        lsp = {
          code = '',
        },
      },
    }
    assert.are.same(expected, result[5])
        end)
      end)
