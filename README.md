# nvim-lint

An asynchronous linter plugin for Neovim (>= 0.5) complementary to the
built-in Language Server Protocol support.

It uses the same API to report diagnostics as the language server client
built-in to neovim would do. Any customizations you did for
`vim.lsp.diagnostic` apply for this plugin as well.


## Motivation & Goals

With [ale][1] we already got an asynchronous linter, why write yet another one?

Because [ale][1] is a full blown linter including a language server client with
its own commands and functions.


`nvim-lint` is for cases where you use the language server protocol client
built into neovim for 90% of the cases, but you want something to fill the
remaining gaps for languages where there is no good language server
implementation or where the diagnostics reporting of the language server is
inadequate and a better standalone linter exists.


## Installation

- Requires Neovim >= 0.5
- `nvim-lint` is a plugin. Install it like any other Neovim plugin.
  - If using [vim-plug][3]: `Plug 'mfussenegger/nvim-lint'`
  - If using [packer.nvim][4]: `use 'mfussenegger/nvim-lint'`


## Usage

Configure the linters you want to run per filetype. For example:

```lua
require('lint').linters_by_ft = {
  markdown = {'vale',}
}
```

Then setup a autocmd to trigger linting. For example:

```vimL
au BufWritePost <buffer> lua require('lint').try_lint()
```

Some linters require a file to be saved to disk, others support linting `stdin`
input. For such linters you could also define a more aggressive autocmd, for
example on the `InsertLeave` or `TextChanged` events.


## Available Linters

There is a generic linter called `compiler` that uses the `makeprg` and
`errorformat` options of the current buffer.

Other dedicated linters that are built-in are:


| Tool                         | Linter name    |
| -------------------          | -------------- |
| Set via `makeprg`            | `compiler`     |
| [ansible-lint][ansible-lint] | `ansible_lint` |
| [checkstyle][checkstyle]     | `checkstyle`   |
| [chktex][20]                 | `chktex`       |
| [clang-tidy][23]             | `clangtidy`    |
| [clazy][30]                  | `clazy`        |
| [clj-kondo][24]              | `clj-kondo`    |
| [codespell][18]              | `codespell`    |
| [cppcheck][22]               | `cppcheck`     |
| [cspell][36]                 | `cspell`       |
| [eslint][25]                 | `eslint`       |
| fennel                       | `fennel`       |
| [Flake8][13]                 | `flake8`       |
| [flawfinder][35]             | `flawfinder`   |
| [Golangci-lint][16]          | `golangcilint` |
| [hadolint][28]               | `hadolint`     |
| [hlint][32]                  | `hlint`        |
| [HTML Tidy][12]              | `tidy`         |
| [Inko][17]                   | `inko`         |
| [jshint][jshint]             | `jshint`       |
| [Languagetool][5]            | `languagetool` |
| [luacheck][19]               | `luacheck`     |
| [markdownlint][26]           | `markdownlint` |
| [mlint][34]                  | `mlint`        |
| [Mypy][11]                   | `mypy`         |
| nix                          | `nix`          |
| [pycodestyle][pcs-docs]      | `pycodestyle`  |
| [pydocstyle][pydocstyle]     | `pydocstyle`   |
| [Pylint][15]                 | `pylint`       |
| [Revive][14]                 | `revive`       |
| [rflint][rflint]             | `rflint`       |
| [robocop][robocop]           | `robocop`      |
| Ruby                         | `ruby`         |
| [Selene][31]                 | `selene`       |
| [ShellCheck][10]             | `shellcheck`   |
| [StandardRB][27]             | `standardrb`   |
| [statix check][33]           | `statix`       |
| [stylelint][29]              | `stylelint`    |
| [Vale][8]                    | `vale`         |
| [vint][21]                   | `vint`         |


## Custom Linters

You can register custom linters by adding them to the `linters` table, but
please consider contributing a linter if it is missing.


```lua
require('lint').linters.your_linter_name = {
  cmd = 'linter_cmd',
  stdin = true, -- or false if it doesn't support content input via stdin. In that case the filename is automatically added to the arguments.
  args = {}, -- list of arguments. Can contain functions with zero arguments that will be evaluated once the linter is used.
  stream = nil, -- ('stdout' | 'stderr' | 'both') configure the stream to which the linter outputs the linting result.
  ignore_exitcode = false, -- set this to true if the linter exits with a code != 0 and that's considered normal.
  env = nil, -- custom environment table to use with the external process. Note that this replaces the *entire* environment, it is not additive.
  parser = your_parse_function
}
```

Instead of declaring the linter as a table, you can also declare it as a
function which returns the linter table in case you want to dynamically
generate some of the properties.

`your_parse_function` can be a function which takes two arguments:

- `output`
- `bufnr`


The `output` is the output generated by the linter command.
The function must return a list of diagnostics as specified in the [language server protocol][9].

You can override the environment that the linting process runs in by setting
the `env` key, e.g.

```lua
env = { ["FOO"] = "bar" }
```

Note that this completely overrides the environment, it does not add new
environment variables. The one exception is that the `PATH` variable will be
preserved if it is not explicitly set.

You can generate a parse function from a Lua pattern or from an `errorformat`
using the function in the `lint.parser` module:

### from_errorformat

```lua
parser = require('lint.parser').from_errorformat(errorformat)
```

The function takes a single argument which is the `errorformat`.


### from_pattern

```lua
parser = require('lint.parser').from_pattern(pattern, groups, severity_map, defaults)
```

The function allows to parse the linter's output using a lua regex pattern.

- pattern: The regex pattern applied on each line of the output
- groups: The groups specified by the pattern

``` lua
groups = {"line", "message", "start_col", ["end_col"], ["code"], ["code_desc"], ["file"], ["severity"]}
```

- severity: A mapping from severity codes to diagnostic codes

``` lua
default_severity = {
['error'] = vim.lsp.protocol.DiagnosticSeverity.Error,
['warning'] = vim.lsp.protocol.DiagnosticSeverity.Warning,
['information'] = vim.lsp.protocol.DiagnosticSeverity.Information,
['hint'] = vim.lsp.protocol.DiagnosticSeverity.Hint,
}
```

- defaults: The defaults diagnostic values

``` lua
defaults = {["source"] = "mylint-name"}
```

<details>
  <summary>Diagnostic interface description</summary>

```typescript
export interface Diagnostic {
    /**
      * The range at which the message applies.
      */
    range: Range;

    /**
      * The diagnostic's severity. Can be omitted. If omitted it is up to the
      * client to interpret diagnostics as error, warning, info or hint.
      */
    severity?: DiagnosticSeverity;

    /**
      * The diagnostic's code, which might appear in the user interface.
      */
    code?: integer | string;

    /**
      * An optional property to describe the error code.
      *
      * @since 3.16.0
      */
    codeDescription?: CodeDescription;

    /**
      * A human-readable string describing the source of this
      * diagnostic, e.g. 'typescript' or 'super lint'.
      */
    source?: string;

    /**
      * The diagnostic's message.
      */
    message: string;

    /**
      * Additional metadata about the diagnostic.
      *
      * @since 3.15.0
      */
    tags?: DiagnosticTag[];

    /**
      * An array of related diagnostic information, e.g. when symbol-names within
      * a scope collide all definitions can be marked via this property.
      */
    relatedInformation?: DiagnosticRelatedInformation[];

    /**
      * A data entry field that is preserved between a
      * `textDocument/publishDiagnostics` notification and
      * `textDocument/codeAction` request.
      *
      * @since 3.16.0
      */
    data?: unknown;
}
```
</details>



## Alternatives

- [null-ls.nvim][null-ls]
- [Ale][1]
- [efm-langserver][6]
- [diagnostic-languageserver][7]


## Development ☢️


### Run tests

Running tests requires [plenary.nvim][plenary] to be checked out in the parent directory of *this* repository.
You can then run:

```bash
nvim --headless --noplugin -u tests/minimal.vim -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal.vim'}"
```

Or if you want to run a single test file:

```bash
nvim --headless --noplugin -u tests/minimal.vim -c "PlenaryBustedDirectory tests/vale_spec.lua {minimal_init = 'tests/minimal.vim'}"
```


[1]: https://github.com/dense-analysis/ale
[3]: https://github.com/junegunn/vim-plug
[4]: https://github.com/wbthomason/packer.nvim
[5]: https://languagetool.org/
[6]: https://github.com/mattn/efm-langserver
[7]: https://github.com/iamcco/diagnostic-languageserver
[8]: https://github.com/errata-ai/vale
[9]: https://microsoft.github.io/language-server-protocol/specifications/specification-current/#diagnostic
[10]: https://www.shellcheck.net/
[11]: http://mypy-lang.org/
[12]: https://www.html-tidy.org/
[13]: https://flake8.pycqa.org/
[14]: https://github.com/mgechev/revive
[15]: https://pylint.org/
[16]: https://golangci-lint.run/
[17]: https://inko-lang.org/
[18]: https://github.com/codespell-project/codespell
[19]: https://github.com/mpeterv/luacheck
[20]: https://www.nongnu.org/chktex
[21]: https://github.com/Vimjas/vint
[22]: https://github.com/danmar/cppcheck/
[23]: https://clang.llvm.org/extra/clang-tidy/
[24]: https://github.com/clj-kondo/clj-kondo
[25]: https://github.com/eslint/eslint
[26]: https://github.com/DavidAnson/markdownlint
[27]: https://github.com/testdouble/standard
[28]: https://github.com/hadolint/hadolint
[29]: https://github.com/stylelint/stylelint
[30]: https://github.com/KDE/clazy
[31]: https://github.com/Kampfkarren/selene
[32]: https://github.com/ndmitchell/hlint
[33]: https://github.com/NerdyPepper/statix
[34]: https://www.mathworks.com/help/matlab/ref/mlint.html
[35]: https://github.com/david-a-wheeler/flawfinder
[36]: https://github.com/streetsidesoftware/cspell/tree/main/packages/cspell
[null-ls]: https://github.com/jose-elias-alvarez/null-ls.nvim
[plenary]: https://github.com/nvim-lua/plenary.nvim
[ansible-lint]: https://docs.ansible.com/lint.html
[pcs-docs]: https://pycodestyle.pycqa.org/en/latest/
[pydocstyle]: https://www.pydocstyle.org/en/stable/
[checkstyle]: https://checkstyle.sourceforge.io/
[jshint]: https://jshint.com/
[rflint]: https://github.com/boakley/robotframework-lint
[robocop]: https://github.com/MarketSquare/robotframework-robocop
