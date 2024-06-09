-- simirian's NeoVim contour
-- tab buffer list component class

--- for BufStatus type
--- @meta buflist.lua

local vfn = vim.fn
local comp = require("contour.components")
local buflist = require("contour.buflist")

--- @class TabBufs : BufList
--- @field close_icon string The clickable icon to close the tab.
local TabBufs = {
  close_icon = "x",
  buffers = {
    buflisted = true,
    bufloaded = true,
  },
}

--- Renders the component.
--- @return string statusline
function TabBufs:render()
  local str = ""
  for tab = 1, vfn.tabpagenr('$') do
    -- highlight based on if tab is active
    if tab == vfn.tabpagenr() then
      str = str .. comp.highlight(self.highlight_sel)
    else
      str = str .. comp.highlight(self.highlight)
    end
    str = str .. self:tabrender(tab)
  end
  return str
end

--- Renders each tab as a number and buffer list
--- @param tabnr number The tab number.
--- @return string statusline
function TabBufs:tabrender(tabnr)
  -- start with tab header and "(TABNR)"
  local str = "%" .. tabnr .. "T (" .. tabnr .. ")"

  for _, bufnr in ipairs(vfn.tabpagebuflist(tabnr)) do
    -- filter based on `buffers` property
    if
        ((not self.buffers.buflisted) or vfn.buflisted(bufnr) == 1)
        and ((not self.buffers.bufloaded) or vfn.bufloaded(bufnr) == 1)
        and ((not self.buffers.bufmodified) or vim.bo[bufnr].modified)
    then
      str = str .. self:bufrender(bufnr)
    end
  end

  return str .. "%" .. tabnr .. "X " .. self.close_icon .. " %X"
end

function TabBufs:bufrender(bufnr)
  oldhl = self.highlight
  oldhls = self.highlight_sel
  self.highlight = ""
  self.highlight_sel = ""
  local rendered = buflist.bufrender(self, bufnr)
  self.highlight = oldhl
  self.highlight_sel = oldhls
  return rendered
end

return comp.apply_metatable(TabBufs, buflist)
