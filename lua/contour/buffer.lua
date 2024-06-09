-- simirian's NeoVim contourbuff
-- buffer component class

local vfn = vim.fn
local comp = require("contour.components")
local devicons_exists, devicons = pcall(require, "nvim-web-devicons")

--- This is the root component for rendering buffers. Many built-in components,
--- including `Buffers` and `TabBufs` will outsource to this component to draw
--- their buffers. Setting values in THIS EXACT table
--- `require("contour.components").Buf.****`
--- will cause buffer rendering to be modified globally. Of course this can
--- always be overridden anywhere you do not want that behavior.
--- @class Buffer : Component
--- @field highlight chl The base highlight group.
--- @field highlight_sel chl The selection highlight group
--- @field filename "filename"|"fullpath"|"relpath"|false The path to the file.
--- @field filetype "icon"|"text"|false How should the filetype be shown.
--- @field default_name string The default name for unnamed buffers.
--- @field modified_icon string|false The icon for modified files.
--- @field show_bufnr boolean Should the bufnr be shown after the filename.
local Buffer = {
  highlight = "",
  highlight_sel = "",
  filename = "filename",
  filetype = devicons_exists and "icon" or "text",
  default_name = "UNKNOWN",
  modified_icon = "+",
  show_bufnr = false,
}

--- Renders a buffer according to the object's settings.
--- Without a given bufnr, renders the current buffer.
--- @param self Buffer The buffer instance.
--- @param bufnr? number The buffer number.
--- @return string
function Buffer:render(bufnr)
  -- get bufnr and bufname
  bufnr = bufnr or vfn.bufnr("%")
  local bufname = vfn.bufname(bufnr)

  -- figure out highlight
  local hl = ""
  if bufnr == vfn.bufnr("%") then
    hl = comp.highlight(self.highlight_sel)
  else
    hl = comp.highlight(self.highlight)
  end

  -- set icon based on bufname
  local ft = ""
  if self.filetype == "icon" then
    local icon = devicons.get_icon(bufname)
    ft = icon or ""
    -- TODO: devicon highlights
    if ft ~= "" then ft = ft .. " " end
  elseif self.filetype == "text" then
    ft = vim.bo[bufnr].filetype .. " "
  end

  -- update bufname based on filename property
  if self.filename then
    if self.filename == "filename" then
      bufname = vfn.fnamemodify(bufname, ":t")
    elseif self.filename == "fullpath" then
      bufname = vfn.fnamemodify(bufname, ":p")
    elseif self.filename == "relpath" then
      bufname = vfn.fnamemodify(bufname, ":p:.")
    end
    if not bufname or bufname == "" then
      bufname = self.default_name
    end
    bufname = bufname .. " "
  end

  -- add bufnr if wanted
  local nr = ""
  if self.show_bufnr then nr = bufnr .. " " end

  -- modified icon
  local mod = ""
  if vim.bo[bufnr].modified and self.modified_icon then
    mod = self.modified_icon .. " "
  end


  -- put it all together
  return hl .. " " .. ft .. bufname .. nr .. mod
end

return comp.apply_metatable(Buffer)
