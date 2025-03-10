-- simirian's NeoVim contour
-- diagnostics component

local util = require("contour.util")

local highlight = util.highlight
local list_extend = vim.list_extend
local diagnostic_count = vim.diagnostic.count
local tbl_deep_extend = vim.tbl_deep_extend

local H = {}
local M = {}

--- @alias Contour.Diagnostics.Type
--- | "error"
--- | "warn"
--- | "info"
--- | "hint"
--- | "default"

--- Displays diagnostics for the requested buffer.
--- @class Contour.Diagnostics
--- @field [1] "diagnostics"
--- Whether or not to show each diagnostic type separately or only the total
--- number of diagnostics.
--- @field show? "each"|"total"
--- Which icons to use for each diagnostic type. "default" is used for when
--- there are no diagnostics, or when the total count is shown.
--- @field icons? table<Contour.Diagnostics.Type, string>
--- Which highlights to use for each diagnostic type. "default" is used for when
--- there are no diagnostics, or when the total count is shown.
--- @field highlights? table<Contour.Diagnostics.Type, string|false>
H.defaults = {
  "diagnostics",
  show = "each",
  icons = {
    error   = "E",
    warn    = "W",
    info    = "I",
    hint    = "H",
    default = "D",
  },
  highlights = {
    error   = "ContourDiagnosticError",
    warn    = "ContourDiagnosticWarn",
    info    = "ContourDiagnosticInfo",
    hint    = "ContourDiagnosticHint",
    default = "ContourDiagnosticDefault",
  },
}

util.default_highlight("ContourDiagnosticError", "DiagnosticError")
util.default_highlight("ContourDiagnosticWarn", "DiagnosticWarn")
util.default_highlight("ContourDiagnosticInfo", "DiagnosticInfo")
util.default_highlight("ContourDiagnosticHint", "DiagnosticHint")
util.default_highlight("ContourDiagnosticDefault", "DiagnosticOk")

H.autocmd = vim.api.nvim_create_autocmd("DiagnosticChanged", {
  callback = function()
    vim.cmd.redrawstatus()
    vim.cmd.redrawtabline()
  end,
})

--- Renders a segment (highlighted icon and count) of diagnostics.
--- @param opts Contour.Diagnostics The diagnostic config to use.
--- @param level integer The level to render for.
--- @param count integer The count of diagnostics to use.
--- @return Contour.Primitive[] segment
function H.segment(opts, level, count)
  local type = ({ [0] = "default", "error", "warn", "info", "hint" })[level]
  return {
    highlight(opts.highlights[type]),
    (" %s %d"):format(opts.icons[type], count),
  }
end

--- Renders diagnostics according to the context and given options.
--- @param opts Contour.Diagnostics The diagnostic config to use for rendering.
--- @param context Contour.Context The buffer and window to be rendering for.
--- @return Contour.Primitive[] line
function M.render(opts, context)
  opts = tbl_deep_extend("keep", opts or {}, H.defaults)
  local counts = diagnostic_count(context.buf)
  local total = (counts[1] or 0) + (counts[2] or 0) + (counts[3] or 0) + (counts[4] or 0)
  local line = {}

  if opts.show == "total" or total == 0 then
    line = H.segment(opts, 0, total)
    line[2] = line[2] .. " "
    return line
  end

  for i = 1, 4 do
    if counts[i] then
      list_extend(line, H.segment(opts, i, counts[i]))
    end
  end
  line[#line] = line[#line] .. " "
  return line
end

return M
