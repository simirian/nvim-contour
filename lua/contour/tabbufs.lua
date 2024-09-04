-- simirian's NeoVim contour
-- tab buffer list component class

local vfn = vim.fn
local comp = require("contour.components")

local H = {}

--- Options to control the TabBuf component's rendering.
--- @class Contour.TabBufs.Opts: Contour.BufList.Opts
--- The highlight group for the currently selected buffer in the active tab
--- page.
--- @field highlight_buf_sel? string
--- The clickable icon to use for closing the rendered tab.
--- @field close_icon? string
H.defaults = setmetatable({
  highlight_buf_sel = "TabLineSel",
  close_icon = "x",
}, { __index = require("contour.buflist").defaults })

--- @class Contour.TabBufs: Contour.BufList
local M = comp.create(H.defaults)

M.render_buffer = require("contour.buffer").render_buffer

--- Renders a tab for the TabBufs component.
--- @param opts Contour.TabBufs.Opts The rendering options.
--- @param tabnr integer The tab page to render.
--- If `tabnr` is 0 or not present then the current tab page will be used.
--- @return string statusline
function M.render_tab(opts, tabnr)
  tabnr = (tabnr == 0 or not tabnr) and vfn.tabpagenr() or tabnr
  local current = tabnr == vfn.tabpagenr()
  local hl = current and comp.highlight(opts.highlight_sel)
      or comp.highlight(opts.highlight)
  local bufs = ""
  local ohl = opts.highlight
  local ohs = opts.highlight_sel
  local ohb = opts.highlight_buf_sel
  if current then
    opts.highlight = ohs
    opts.highlight_sel = ohb
  else
    opts.highlight = ohl
    opts.highlight_sel = ohl
  end
  for _, bufnr in ipairs(vfn.tabpagebuflist(tabnr)) do
    if opts.filter(bufnr) then
      bufs = bufs .. M.render_buffer(opts, bufnr)
    end
  end
  opts.highlight = ohl
  opts.highlight_sel = ohs
  opts.highlight_buf_sel = ohb
  return ("%s%%%dT (%d) %s%%%dX%s %%X"):format(
    hl, tabnr, tabnr, bufs, tabnr, opts.close_icon)
end

--- Renders a list of tabs and their open buffers.
--- @param opts Contour.TabBufs.Opts The rendering options.
--- @return string statusline
function M.render(opts)
  local str = ""
  for tabnr = 1, vfn.tabpagenr("$") do
    str = str .. M.render_tab(opts, tabnr)
  end
  return str
end

return M
