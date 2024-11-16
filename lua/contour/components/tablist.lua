-- simirian's NeoVim contour
-- tab list component

local tab = require("contour.components.tab")

local copy = vim.deepcopy
local tabpagenr = vim.fn.tabpagenr
local list_extend = vim.list_extend
local tbl_deep_extend = vim.tbl_deep_extend

local H = {}
local M = {}

--- Renders a list of the currently open tabs.
--- @class Contour.Tablist
--- @field [1] "tablist"
--- The config for rendering each individual tab.
--- @field tab? Contour.Tab
H.defaults = {
  "tablist",
  tab = nil,
}

--- Renders the tab list.
--- @param opts Contour.Tablist The rendering options.
--- @param context Contour.Context The context to render in.
-- @return Contour.Primitive[] line
function M.render(opts, context)
  opts = tbl_deep_extend("keep", opts or {}, H.defaults)
  local line = {}
  local curtab = tabpagenr()
  local ctx = copy(context)

  for t = 1, tabpagenr("$") do
    ctx.tab = t
    ctx.current = t == curtab
    list_extend(line, tab.render(opts.tab, ctx))
    -- TODO: truncation
  end

  return line
end

return M
