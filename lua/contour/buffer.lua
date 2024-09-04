-- simirian's NeoVim contourbuff
-- buffer component class

local vfn = vim.fn
local comp = require("contour.components")
local devicons_exists, devicons = pcall(require, "nvim-web-devicons")

local H = {}

--- Options to control buffer rendering.
--- @class Contour.Buffer.Opts
--- How to display the file name.
---   "filename" will show the basename of the file
---   "fullpath" will show the file's full path
---   "relpath" will show the `":~:."` relative path
--- @field filename? "filename"|"fullpath"|"relpath"
--- How to display the file type.
---   "text" will just show the 'filetype' option
---   "icon" will get the icon from nvim_web_devicons
--- @field filetype? "text"|"icon"
--- The name for buffers which aren't files.
--- @field default_name? string
--- The icon to show when a buffer is modified. If false no icon will be shown.
--- @field modified_icon? string|false
--- Shows the buffer number after its name.
--- @field show_bufnr? boolean
H.defaults = {
  highlight = nil,
  highlight_sel = nil,
  filename = "filename",
  filetype = "text",
  default_name = "UNKNOWN",
  modified_icon = "*",
  show_bufnr = false,
}

--- @class Contour.Buffer: Contour.Component
local M = comp.create(H.defaults)

--- Renders a buffer according to the options if finds.
--- @param opts Contour.Buffer.Opts The rendering options.
--- @param bufnr integer The buffer to render.
--- If `bufnr` is 0 or not present the current buffer will be used.
--- @return string statusline
function M.render_buffer(opts, bufnr)
  bufnr = (bufnr == 0 or not bufnr) and vfn.bufnr() or bufnr
  local bi = vfn.getbufinfo(bufnr)[1]
  local current = bufnr == vfn.bufnr(vfn.getreg("%"))

  local hl = current and comp.highlight(opts.highlight_sel)
      or comp.highlight(opts.highlight)

  local bn = (opts.filename == "filename" and vfn.fnamemodify(bi.name, ":t"))
      or (opts.filename == "fullpath" and vfn.fnamemodify(bi.name, ":p"))
      or (opts.filename == "relpath" and vfn.fnamemodify(bi.name, ":p:~:."))
  if not bn or bn == "" then bn = opts.default_name end

  local ft = ""
  if bn == opts.default_name then
  elseif opts.filetype == "icon" and devicons_exists then
    ft = devicons.get_icon(bi.name, vfn.fnamemodify(bi.name, ":e"),
      { default = true }) .. " "
  else
    ft = "(" .. vim.bo[bufnr].filetype .. ") "
  end

  local nr = opts.show_bufnr and " " .. bufnr or ""

  local mod = bi.changed == 1 and opts.modified_icon .. " " or ""

  return ("%s %s%s%s %s"):format(hl, ft, bn, nr, mod)
end

--- Renders a buffer.
--- @param opts Contour.Buffer.Opts The rendering options.
--- @return string statusline
function M.render(opts) return M.render_buffer(opts, 0) end

return M
