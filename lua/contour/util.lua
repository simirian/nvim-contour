-- simirian's NeoVim contour
-- util module

local winbuf = vim.api.nvim_win_get_buf
local winwid = vim.api.nvim_win_get_width
local curwin = vim.api.nvim_get_current_win
local curtab = vim.api.nvim_get_current_tabpage

--- @class Contour.Context
--- The buffer to render for.
--- @field buf integer
--- The window to render for.
--- @field win integer
--- The tab to render for.
--- @field tab integer
--- If this component should be rendered as the current component.
--- @field current boolean
--- The maximum width that the component is being given.
--- @field max_width integer

--- @alias Contour.Component
--- | Contour.Buffer
--- | Contour.Diagnostics

local M = {}

--- Creates a statusline string for highlighting. If group is nil or false, then
--- there will be no change. If group is an empty string, then the highlight
--- will be reset. Otherwise group is used as a highlight group name
--- @param group? string|false The group to set highlighting to.
--- @return Contour.Primitive statusline
function M.highlight(group)
  if not group then return end
  if group == "" then return function() return "%*" end end
  return function() return "%#" .. group .. "#" end
end

--- Creates a rendering context based on the current nvim state.
--- @param scope "global"|"window"
--- @return Contour.Context
function M.make_context(scope)
  local context = {}
  context.win = scope == "global" and curwin() or vim.g.statusline_winid
  context.buf = winbuf(context.win)
  context.tab = curtab()
  context.current = context.win == curwin()
  context.max_width = scope == "window" and winwid(context.win) or vim.o.columns
  return context
end

--- Prints an error message for a module.
function M.error(module, msg)
  vim.notify("nvim-contour " .. module .. ":\n    " .. msg:gsub("\n", "\n    "))
end

--- Prints an error messsage for a module one time.
function M.error_once(module, msg)
  vim.notify_once("nvim-contour " .. module .. ":\n    " .. msg:gsub("\n", "\n    "))
end

return M
