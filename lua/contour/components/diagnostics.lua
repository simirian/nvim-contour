-- simirian's NeoVim contour
-- diagnostics component class

local vfn = vim.fn
local util = require("contour.util")

local H = {}

--- @alias Contour.Diagnostics.Type
--- | "error"
--- | "warn"
--- | "info"
--- | "hint"
--- | "base"

--- Options for the diagnostics component.
--- @class Contour.Diagnostics.Opts
--- The highlight groups for each type of diagnostic, or a string for the whole
--- component.
--- @field highlight? string|table<Contour.Diagnostics.Type, string>
--- The icons for the component to display.
--- @field icons? table<Contour.Diagnostics.Type, string>
--- How to show diagnostics.
---   "all" will show each type of diagnostic there is individually.
---   "total" will only show the total number of diagnostics.
--- @field show? "all"|"total"
H.defaults = {
  highlight = nil,
  icons = {
    error = "e",
    warn = "w",
    info = "i",
    hint = "h",
    base = "!!",
  },
  show = "all",
}

--- @class Contour.Diagnostics: Contour.Component
local M = util.component(H.defaults)

--- Renders a buffer's diagnostics.
--- @param opts Contour.Diagnostics.Opts The rendering options.
--- @param bufnr integer The buffer to render diagnostics for.
--- If `bufnr` is 0 or not present the current buffer will be used.
--- @return string statusline
function M.render_diagnostics(opts, bufnr)
  bufnr = (bufnr == 0 or not bufnr) and vfn.bufnr() or bufnr
  local counts = vim.diagnostic.count(bufnr)
  local total = 0
  for _, v in pairs(counts) do total = total + v end
  local str = ""

  local bhl = ""
  if type(opts.highlight) == "string" then
    bhl = util.highlight(opts.highlight --[[ @as string ]])
  elseif type(opts.highlight) == "table" and opts.highlight.base then
    bhl = util.highlight(opts.highlight.base)
  end
  str = str .. bhl

  if opts.show == "total" or total == 0 then
    return str .. (" %s %d "):format(opts.icons.base, total)
  end
  for level = 1, 4 do
    if counts[level] then
      local severity = vim.diagnostic.severity[level]:lower()
      local icon = opts.icons[severity]
      local hl = ""
      if type(opts.highlight) == "table" then
        hl = opts.highlight[severity]
            and util.highlight(opts.highlight[severity]) or bhl
      end
      str = str .. ("%s %s %d"):format(hl, icon, counts[level])
    end
  end
  return str .. " "
end

--- Renders a buffer's diagnostics.
--- @param opts Contour.Diagnostics.Opts Teh rendering options.
--- @return string statusline
function M.render(opts) return M.render_diagnostics(opts, 0) end

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = vim.api.nvim_create_augroup("NvimContour", { clear = false }),
  command = "redrawstatus|redrawstatus",
})

return M
