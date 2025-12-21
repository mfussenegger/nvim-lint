local severities = {
  High = vim.diagnostic.severity.ERROR,
  Medium = vim.diagnostic.severity.WARN,
  Low = vim.diagnostic.severity.INFO,
  Informational = vim.diagnostic.severity.HINT,
}

return {
  cmd = "zizmor",
  args = { "--format", "json-v1" },
  stdin = false,
  ignore_exitcode = true,

  parser = function(output, _)
    local items = {}

    if output == "" then
      return items
    end

    local decoded = vim.json.decode(output) or {}

    for _, diag in ipairs(decoded) do
      ---@type lsp.DiagnosticRelatedInformation[]
      local related = {}
      for _, loc in
        ipairs(diag.locations)
      do
        local fname = loc.symbolic.key.Local.given_path
        related[#related + 1] = {
          message = loc.symbolic.annotation,
          location = {
            uri = vim.uri_from_fname(fname),
            range = {
              ["start"] = {
                line = loc.concrete.location.start_point.row,
                character = loc.concrete.location.start_point.column,
              },
              ["end"] = {
                line = loc.concrete.location.end_point.row,
                character = loc.concrete.location.end_point.column,
              },
            },
          },
        }
      end
      table.sort(related, function(loc1, loc2)
        if loc1.location.range.start.line == loc2.location.range.start.line then
          if loc1.location.range.start.character == loc2.location.range.start.character then
            return loc1.message < loc2.message
          else
            return loc1.location.range.start.character < loc2.location.range.start.character
          end
        else
          return loc1.location.range.start.line < loc2.location.range.start.line
        end
      end)

      local primary = vim.tbl_filter(function(item)
        return item.symbolic.kind == "Primary"
      end, diag.locations)[1]

      local location = primary.concrete.location
      table.insert(items, {
        source = "zizmor",
        lnum = location.start_point.row,
        col = location.start_point.column,
        end_lnum = location.end_point.row,
        end_col = location.end_point.column,
        message = diag.desc,
        code = diag.ident,
        severity = assert(
          severities[diag.determinations.severity],
          "missing mapping for severity " .. diag.determinations.severity
        ),
        user_data = {
          lsp = {
            codeDescription = {
              href = diag.url,
            },
            relatedInformation = related,
          },
        },
      })
    end

    return items
  end,
}
