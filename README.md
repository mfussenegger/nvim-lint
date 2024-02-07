# nvim-lint

An asynchronous linter plugin for Neovim (>= 0.6.0) complementary to the
built-in Language Server Protocol support.

## Motivation & Goals

With [ale][1] we already got an asynchronous linter, why write yet another one?

Because [ale][1] also includes its own language server client.

`nvim-lint` instead has a more narrow scope: It spawns linters, parses their
output, and reports the results via the `vim.diagnostic` module.

`nvim-lint` complements the built-in language server client for languages where
there are no language servers, or where standalone linters provide better
results.

## Installation

- Requires Neovim >= 0.6.0
- `nvim-lint` is a regular plugin and can be installed via the `:h packages`
  mechanism or via a plugin manager.

For example:

```bash
git clone \
    https://github.com/mfussenegger/nvim-lint.git
    ~/.config/nvim/pack/plugins/start/nvim-lint
```

- If using [vim-plug][3]: `Plug 'mfussenegger/nvim-lint'`
- If using [packer.nvim][4]: `use 'mfussenegger/nvim-lint'`


## Usage

Configure the linters you want to run per file type. For example:

```lua
require('lint').linters_by_ft = {
  markdown = {'vale',}
}
```

Then setup a autocmd to trigger linting. For example:

```vimL
au BufWritePost * lua require('lint').try_lint()
```

or with Lua autocmds (requires 0.7):

```lua
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()

    -- try_lint without arguments runs the linters defined in `linters_by_ft`
    -- for the current filetype
    require("lint").try_lint()

    -- You can call `try_lint` with a linter name or a list of names to always
    -- run specific linters, independent of the `linters_by_ft` configuration
    require("lint").try_lint("cspell")
  end,
})
```

Some linters require a file to be saved to disk, others support linting `stdin`
input. For such linters you could also define a more aggressive autocmd, for
example on the `InsertLeave` or `TextChanged` events.


If you want to customize how the diagnostics are displayed, read `:help
vim.diagnostic.config`.


## Available Linters

There is a generic linter called `compiler` that uses the `makeprg` and
`errorformat` options of the current buffer.

Other dedicated linters that are built-in are:

| Tool                                   | Linter name            |
| -------------------------------------- | ---------------------- |
| Set via `makeprg`                      | `compiler`             |
| [actionlint][actionlint]               | `actionlint`           |
| [alex][alex]                           | `alex`                 |
| [ansible-lint][ansible-lint]           | `ansible_lint`         |
| [bandit][bandit]                       | `bandit`               |
| [bean-check][bean-check]               | `bean_check`           |
| [biomejs][biomejs]                     | `biomejs`              |
| [blocklint][blocklint]                 | `blocklint`            |
| [buf_lint][buf_lint]                   | `buf_lint`             |
| [buildifier][buildifier]               | `buildifier`           |
| [cfn-lint][cfn-lint]                   | `cfn_lint`             |
| [cfn_nag][cfn_nag]                     | `cfn_nag`              |
| [checkmake][checkmake]                 | `checkmake`            |
| [checkpatch.pl][checkpatch]            | `checkpatch`           |
| [checkstyle][checkstyle]               | `checkstyle`           |
| [chktex][20]                           | `chktex`               |
| [clang-tidy][23]                       | `clangtidy`            |
| [clazy][30]                            | `clazy`                |
| [clj-kondo][24]                        | `clj-kondo`            |
| [cmakelint][cmakelint]                 | `cmakelint`            |
| [codespell][18]                        | `codespell`            |
| [commitlint][commitlint]               | `commitlint`           |
| [cppcheck][22]                         | `cppcheck`             |
| [cpplint][cpplint]                     | `cpplint`              |
| [credo][credo]                         | `credo`                |
| [cspell][36]                           | `cspell`               |
| [cue][cue]                             | `cue`                  |
| [curlylint][curlylint]                 | `curlylint`            |
| [dash][dash]                           | `dash`                 |
| [deadnix][deadnix]                     | `deadnix`              |
| [deno][deno]                           | `deno`                 |
| [DirectX Shader Compiler][dxc]         | `dxc`                  |
| [djlint][djlint]                       | `djlint`               |
| [dotenv-linter][dotenv-linter]         | `dotenv_linter`        |
| [editorconfig-checker][ec]             | `editorconfig-checker` |
| [erb-lint][erb-lint]                   | `erb_lint`             |
| [ESLint][25]                           | `eslint`               |
| [eslint_d][37]                         | `eslint_d`             |
| [fennel][fennel]                       | `fennel`               |
| [fish][fish]                           | `fish`                 |
| [Flake8][13]                           | `flake8`               |
| [flawfinder][35]                       | `flawfinder`           |
| [gdlint (gdtoolkit)][gdlint]           | `gdlint`               |
| [GHDL][ghdl]                           | `ghdl`                 |
| [gitlint][gitlint]                     | `gitlint`              |
| [glslc][glslc]                         | `glslc`                |
| [Golangci-lint][16]                    | `golangcilint`         |
| [hadolint][28]                         | `hadolint`             |
| [hlint][32]                            | `hlint`                |
| [htmlhint][htmlhint]                   | `htmlhint`             |
| [HTML Tidy][12]                        | `tidy`                 |
| [Inko][17]                             | `inko`                 |
| [janet][janet]                         | `janet`                |
| [joker][joker]                         | `joker`                |
| [jshint][jshint]                       | `jshint`               |
| [jsonlint][jsonlint]                   | `jsonlint`             |
| [ktlint][ktlint]                       | `ktlint`               |
| [lacheck][lacheck]                     | `lacheck`              |
| [Languagetool][5]                      | `languagetool`         |
| [luacheck][19]                         | `luacheck`             |
| [markdownlint][26]                     | `markdownlint`         |
| [markdownlint-cli2][markdownlint-cli2] | `markdownlint-cli2`    |
| [markuplint][markuplint]               | `markuplint`           |
| [mlint][34]                            | `mlint`                |
| [Mypy][11]                             | `mypy`                 |
| [Nagelfar][nagelfar]                   | `nagelfar`             |
| [Nix][nix]                             | `nix`                  |
| [npm-groovy-lint][npm-groovy-lint]     | `npm-groovy-lint`      |
| [oelint-adv][oelint-adv]               | `oelint-adv`           |
| [opa_check][opa_check]                 | `opa_check`            |
| [oxlint][oxlint]                       | `oxlint`               |
| [perlcritic][perlcritic]               | `perlcritic`           |
| [perlimports][perlimports]             | `perlimports`          |
| [phpcs][phpcs]                         | `phpcs`                |
| [phpinsights][phpinsights]             | `phpinsights`          |
| [phpmd][phpmd]                         | `phpmd`                |
| [php][php]                             | `php`                  |
| [phpstan][phpstan]                     | `phpstan`              |
| [ponyc][ponyc]                         | `pony`                 |
| [prisma-lint][prisma-lint]             | `prisma-lint`          |
| [proselint][proselint]                 | `proselint`            |
| [protolint][protolint]                 | `protolint`            |
| [psalm][psalm]                         | `psalm`                |
| [puppet-lint][puppet-lint]             | `puppet-lint`          |
| [pycodestyle][pcs-docs]                | `pycodestyle`          |
| [pydocstyle][pydocstyle]               | `pydocstyle`           |
| [Pylint][15]                           | `pylint`               |
| [pyproject-flake8][pflake8]            | `pflake8`              |
| [quick-lint-js][quick-lint-js]         | `quick-lint-js`        |
| [regal][regal]                         | `regal`                |
| [Revive][14]                           | `revive`               |
| [rflint][rflint]                       | `rflint`               |
| [robocop][robocop]                     | `robocop`              |
| [RPM][rpm]                             | `rpmspec`              |
| [rstcheck][rstcheck]                   | `rstcheck`             |
| [rstlint][rstlint]                     | `rstlint`              |
| [RuboCop][rubocop]                     | `rubocop`              |
| [Ruby][ruby]                           | `ruby`                 |
| [Ruff][ruff]                           | `ruff`                 |
| [salt-lint][salt-lint]                 | `saltlint`             |
| [Selene][31]                           | `selene`               |
| [ShellCheck][10]                       | `shellcheck`           |
| [snyk][snyk]                           | `snyk_iac`             |
| [Solhint][solhint]                     | `solhint`              |
| [Spectral][spectral]                   | `spectral`             |
| [sqlfluff][sqlfluff]                   | `sqlfluff`             |
| [standardjs][standardjs]               | `standardjs`           |
| [StandardRB][27]                       | `standardrb`           |
| [statix check][33]                     | `statix`               |
| [stylelint][29]                        | `stylelint`            |
| [SwiftLint][swiftlint]                 | `swiftlint`            |
| [systemdlint][systemdlint]             | `systemdlint`          |
| [tflint][tflint]                       | `tflint`               |
| [tfsec][tfsec]                         | `tfsec`                |
| [tlint][tlint]                         | `tlint`                |
| [trivy][trivy]                         | `trivy`                |
| [typos][typos]                         | `typos`                |
| [Vala][vala-lint]                      | `vala_lint`            |
| [Vale][8]                              | `vale`                 |
| [Verilator][verilator]                 | `verilator`            |
| [vint][21]                             | `vint`                 |
| [vulture][vulture]                     | `vulture`              |
| [woke][woke]                           | `woke`                 |
| [write-good][write-good]               | `write_good`           |
| [yamllint][yamllint]                   | `yamllint`             |
| [zsh][zsh]                             | `zsh`                  |

## Custom Linters

You can register custom linters by adding them to the `linters` table, but
please consider contributing a linter if it is missing.


```lua
require('lint').linters.your_linter_name = {
  cmd = 'linter_cmd',
  stdin = true, -- or false if it doesn't support content input via stdin. In that case the filename is automatically added to the arguments.
  append_fname = true, -- Automatically append the file name to `args` if `stdin = false` (default: true)
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

`your_parse_function` can be a function which takes three arguments:

- `output`
- `bufnr`
- `linter_cwd`


The `output` is the output generated by the linter command.
The function must return a list of diagnostics as specified in `:help
diagnostic-structure`.

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

The function takes two arguments: `errorformat` and `skeleton` (optional).


### from_pattern

```lua
parser = require('lint.parser').from_pattern(pattern, groups, severity_map, defaults, opts)
```

The function allows to parse the linter's output using a Lua regular expression pattern.

- pattern: The regular expression pattern applied on each line of the output
- groups: The groups specified by the pattern

Available groups:

- `lnum`
- `end_lnum`
- `col`
- `end_col`
- `message`
- `file`
- `severity`
- `code`

The order of the groups must match the order of the captures within the pattern.
An example:

```lua
local pattern = '[^:]+:(%d+):(%d+):(%w+):(.+)'
local groups = { 'lnum', 'col', 'code', 'message' }
```

- severity: A mapping from severity codes to diagnostic codes

``` lua
default_severity = {
['error'] = vim.diagnostic.severity.ERROR,
['warning'] = vim.diagnostic.severity.WARN,
['information'] = vim.diagnostic.severity.INFO,
['hint'] = vim.diagnostic.severity.HINT,
}
```

- defaults: The defaults diagnostic values

```lua
defaults = {["source"] = "mylint-name"}
```

- opts: Additional options

  - `lnum_offset`: Added to `lnum`. Defaults to 0
  - `end_lnum_offset`: Added to `end_lnum`. Defaults to 0
  - `end_col_offset`: offset added to `end_col`. Defaults to `-1`, assuming
    that the end-column position is exclusive.


## Customize built-in linters

You can import a linter and modify its properties. An example:

```lua
local phpcs = require('lint').linters.phpcs
phpcs.args = {
  '-q',
  -- <- Add a new parameter here
  '--report=json',
  '-'
}
```

You can also post-process the diagnostics produced by a linter by wrapping it.
For example, to change the severity of all diagnostics created by `cspell`:

```lua
local lint = require("lint")
lint.linters.cspell = require("lint.util").wrap(lint.linters.cspell, function(diagnostic)
  diagnostic.severity = vim.diagnostic.severity.HINT
  return diagnostic
end)
```


## Display configuration

See `:help vim.diagnostic.config`.

If you want to have different settings per linter, you can get the `namespace`
for a linter via `require("lint").get_namespace("linter_name")`. An example:

```lua
local ns = require("lint").get_namespace("my_linter_name")
vim.diagnostic.config({ virtual_text = true }, ns)
```


## Get the current running linters for your buffer

You can see which linters are running with `require("lint").get_running()`.
To include the running linters in the status line you could format them like this:

```lua
local lint_progress = function()
  local linters = require("lint").get_running()
  if #linters == 0 then
      return "󰦕"
  end
  return "󱉶 " .. table.concat(linters, ", ")
end
```


## Alternatives

- [Ale][1]
- [efm-langserver][6]
- [diagnostic-languageserver][7]


## Development ☢️


### Run tests

Running tests requires [busted][busted].

See [neorocks][neorocks] or [Using Neovim as Lua interpreter with
Luarocks][neovim-luarocks] for installation instructions.

```bash
busted tests/
```

[1]: https://github.com/dense-analysis/ale
[3]: https://github.com/junegunn/vim-plug
[4]: https://github.com/wbthomason/packer.nvim
[5]: https://languagetool.org/
[6]: https://github.com/mattn/efm-langserver
[7]: https://github.com/iamcco/diagnostic-languageserver
[8]: https://github.com/errata-ai/vale
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
[37]: https://github.com/mantoni/eslint_d.js
[neorocks]: https://github.com/nvim-neorocks/neorocks
[neovim-luarocks]: https://zignar.net/2023/01/21/using-luarocks-as-lua-interpreter-with-luarocks/
[busted]: https://lunarmodules.github.io/busted/
[ansible-lint]: https://docs.ansible.com/lint.html
[pcs-docs]: https://pycodestyle.pycqa.org/en/latest/
[pydocstyle]: https://www.pydocstyle.org/en/stable/
[prisma-lint]: https://github.com/loop-payments/prisma-lint
[checkpatch]: https://docs.kernel.org/dev-tools/checkpatch.html
[checkstyle]: https://checkstyle.sourceforge.io/
[jshint]: https://jshint.com/
[jsonlint]: https://github.com/zaach/jsonlint
[rflint]: https://github.com/boakley/robotframework-lint
[robocop]: https://github.com/MarketSquare/robotframework-robocop
[vulture]: https://github.com/jendrikseipp/vulture
[yamllint]: https://github.com/adrienverge/yamllint
[cpplint]: https://github.com/cpplint/cpplint
[proselint]: https://github.com/amperser/proselint
[protolint]: https://github.com/yoheimuta/protolint
[cmakelint]: https://github.com/cmake-lint/cmake-lint
[rstcheck]: https://github.com/myint/rstcheck
[rstlint]: https://github.com/twolfson/restructuredtext-lint
[ktlint]: https://github.com/pinterest/ktlint
[php]: https://www.php.net/
[phpcs]: https://github.com/squizlabs/PHP_CodeSniffer
[phpinsights]: https://github.com/nunomaduro/phpinsights
[phpmd]: https://phpmd.org/
[phpstan]: https://phpstan.org/
[psalm]: https://psalm.dev/
[lacheck]: https://www.ctan.org/tex-archive/support/lacheck
[credo]: https://github.com/rrrene/credo
[ghdl]: https://github.com/ghdl/ghdl
[glslc]: https://github.com/google/shaderc
[rubocop]: https://github.com/rubocop/rubocop
[dxc]: https://github.com/microsoft/DirectXShaderCompiler
[cfn-lint]: https://github.com/aws-cloudformation/cfn-lint
[fennel]: https://github.com/bakpakin/Fennel
[nix]: https://github.com/NixOS/nix
[ruby]: https://github.com/ruby/ruby
[npm-groovy-lint]: https://github.com/nvuillam/npm-groovy-lint
[nagelfar]: https://nagelfar.sourceforge.net/
[oelint-adv]: https://github.com/priv-kweihmann/oelint-adv
[cfn_nag]: https://github.com/stelligent/cfn_nag
[checkmake]: https://github.com/mrtazz/checkmake
[ruff]: https://github.com/astral-sh/ruff
[janet]: https://github.com/janet-lang/janet
[bandit]: https://bandit.readthedocs.io/en/latest/
[bean-check]: https://beancount.github.io/docs/running_beancount_and_generating_reports.html#bean-check
[cue]: https://github.com/cue-lang/cue
[curlylint]: https://www.curlylint.org/
[sqlfluff]: https://github.com/sqlfluff/sqlfluff
[verilator]: https://verilator.org/guide/latest/
[actionlint]: https://github.com/rhysd/actionlint
[buf_lint]: https://github.com/bufbuild/buf
[erb-lint]: https://github.com/shopify/erb-lint
[tfsec]: https://github.com/aquasecurity/tfsec
[tlint]: https://github.com/tighten/tlint
[trivy]: https://github.com/aquasecurity/trivy
[djlint]: https://djlint.com/
[buildifier]: https://github.com/bazelbuild/buildtools/tree/master/buildifier
[solhint]: https://protofire.github.io/solhint/
[perlimports]: https://github.com/perl-ide/App-perlimports
[perlcritic]: https://github.com/Perl-Critic/Perl-Critic
[ponyc]: https://github.com/ponylang/ponyc
[gdlint]: https://github.com/Scony/godot-gdscript-toolkit
[rpm]: https://rpm.org
[ec]: https://github.com/editorconfig-checker/editorconfig-checker
[deno]: https://github.com/denoland/deno
[standardjs]: https://standardjs.com/
[biomejs]: https://github.com/biomejs/biome
[commitlint]: https://commitlint.js.org
[alex]: https://alexjs.com/
[blocklint]: https://github.com/PrincetonUniversity/blocklint
[woke]: https://docs.getwoke.tech/
[write-good]: https://github.com/btford/write-good
[dotenv-linter]: https://dotenv-linter.github.io/
[puppet-lint]: https://github.com/puppetlabs/puppet-lint
[snyk]: https://github.com/snyk/cli
[spectral]: https://github.com/stoplightio/spectral
[gitlint]: https://github.com/jorisroovers/gitlint
[pflake8]: https://github.com/csachs/pyproject-flake8
[fish]: https://github.com/fish-shell/fish-shell
[zsh]: https://www.zsh.org/
[typos]: https://github.com/crate-ci/typos
[joker]: https://github.com/candid82/joker
[dash]: http://gondor.apana.org.au/~herbert/dash
[deadnix]: https://github.com/astro/deadnix
[salt-lint]: https://github.com/warpnet/salt-lint
[quick-lint-js]: https://quick-lint-js.com
[opa_check]: https://www.openpolicyagent.org/
[oxlint]: https://oxc-project.github.io/
[regal]: https://github.com/StyraInc/regal
[vala-lint]: https://github.com/vala-lang/vala-lint
[systemdlint]: https://github.com/priv-kweihmann/systemdlint
[htmlhint]: https://htmlhint.com/
[markuplint]: https://markuplint.dev/
[markdownlint-cli2]: https://github.com/DavidAnson/markdownlint-cli2
[swiftlint]: https://github.com/realm/SwiftLint
[tflint]: https://github.com/terraform-linters/tflint
