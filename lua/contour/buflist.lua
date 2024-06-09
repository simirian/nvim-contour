-- simirian's NeoVim contour
-- buffer list component class

local vfn = vim.fn
local comp = require("contour.components")
local buf = require("contour.buffer")

--- @alias bufstatus {buflisted?: boolean, bufloaded?: boolean, bufmodified?: boolean}

--- A list of buffers displayed according to the `Buffer` component.
--- @class BufList : Buffer
--- @field highlight_sel chl The selection highlight group.
--- @field buffers bufstatus What buffers to include.
--- @field bufrender fun(Component, number): string How to render each buffer.
local BufList = {
  highlight = "TabLine",
  highlight_sel = "TabLineSel",
  buffers = {
    buflisted = true,
    bufloaded = true,
  },

  -- render buffers with the generic function
  bufrender = buf.render,
}

--- Renders a list of buffers.
--- @return string statusline
function BufList:render()
  local str = ""
  for _, buffer in ipairs(vfn.getbufinfo(self.buffers)) do
    str = str .. self:bufrender(buffer.bufnr)
  end
  return str
end

return comp.apply_metatable(BufList, buf)
