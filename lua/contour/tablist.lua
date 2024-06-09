-- simirian's NeoVim contour
-- tab component class

local vfn = vim.fn
local comp = require("contour.components")

--- This component lists tabs by their tabnr.
--- @class TabList : Component
--- @field highlight_sel chl The selection highlight group.
--- @field close_icon string|false The clickable icon to close the tab.
--- @field modified_icon string|false Shows if a tab is modified.
local TabList = {
  highlight = "TabLine",
  highlight_sel = "TabLineSel",
  close_icon = "x",
  modified_icon = "+",
}

--- Renders a tab list statusline.
--- @return string statusline
function TabList:render()
  local str = ""
  for tab = 1, vfn.tabpagenr("$") do
    str = str .. self:tabrender(tab)
  end
  return str
end

--- Renders each tab page.
--- @param self TabList The tabs object with rendering settings.
--- @param tabnr? number The tab number to render.
--- @return string statusline
function TabList:tabrender(tabnr)
  tabnr = tabnr or vfn.tabpagenr()

  -- get highlights
  local hl = ""
  if vfn.tabpagenr() == tabnr then
    hl = comp.highlight(self.highlight_sel)
  else
    hl = comp.highlight(self.highlight)
  end

  -- set the icon to close or modified
  local bufs = vfn.tabpagebuflist()
  local icon = self.close_icon
  for _, bufnr in ipairs(bufs) do
    if vim.bo[bufnr].modified
        and vim.bo[bufnr].buflisted
        and vfn.bufloaded(bufnr) == 1
    then
      icon = self.modified_icon
    end
  end

  -- stitch it together
  return hl .. "%" .. tabnr .. "T " .. tabnr .. " %" .. tabnr .. "X" .. icon
      .. " %X"
end

return comp.apply_metatable(TabList)
