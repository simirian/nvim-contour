-- simirian's NeoVim contour
-- tab component class

local vfn = vim.fn
local util = require("contour.util")

local H = {}

--- This component lists tabs by their tabnr.
--- @class Contour.TabList.Opts
--- The highlight for non-selected tabs.
--- @field highlight? string
--- The highlight of the currently selected tab.
--- @field highlight_sel? string
--- The clickable icon for closing the tab
--- @field close_icon? string
--- The icon that shows if the tab has modified buffers.
--- @field modified_icon? string|false
H.defaults = {
  highlight = "TabLine",
  highlight_sel = "TabLineSel",
  close_icon = "x",
  modified_icon = "*",
}

--- @class Contour.TabList: Contour.Component
local M = util.component(H.defaults, "tablist")

--- Renders a tab for the TabList component.
--- @param opts Contour.TabList.Opts The rendering options.
--- @param tabnr integer The tab page to render.
--- If `tabnr` is 0 or not present the current tab will be used.
--- @return string statusline
function M.render_tab(opts, tabnr)
  tabnr = (tabnr == 0 or not tabnr) and vfn.tabpagenr() or tabnr
  local current = tabnr == vfn.tabpagenr()
  local hl = util.highlight(current and opts.highlight_sel or opts.highlight)
  local mod = ""
  for _, bufnr in ipairs(vfn.tabpagebuflist(tabnr)) do
    if vim.bo[bufnr].modified
        and vim.bo[bufnr].buflisted
    then
      mod = " " .. opts.modified_icon
    end
  end
  return ("%s%%%dT %d%s %%%dX%s %%X"):format(
    hl, tabnr, tabnr, mod, tabnr, opts.close_icon)
end

--- Renders the tab list.
--- @param opts Contour.TabList.Opts The rendering options.
--- @return string statusline
function M.render(opts)
  local str = ""
  for tabnr = 1, vfn.tabpagenr("$") do
    str = str .. M.render_tab(opts, tabnr)
  end
  return str
end

return M
