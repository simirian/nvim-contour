-- simirian's NeoVim contour
-- util module

local winbuf = vim.api.nvim_win_get_buf
local winwid = vim.api.nvim_win_get_width
local curwin = vim.api.nvim_get_current_win
local curtab = vim.fn.tabpagenr

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
--- @field width integer

--- @alias Contour.Component
--- | Contour.Group
--- | Contour.Space
--- | Contour.Raw
--- | Contour.Function
--- | Contour.Buffer
--- | Contour.Buflist
--- | Contour.Tab
--- | Contour.Diagnostics

local M = {}
local H = {}

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

--- default highlight links to refresh on :colorscheme
--- @type table<string, string>
H.highlights = {}

--- Creates a highlight group if it doesn't yet exist
--- @param group string The group to create.
--- @param link string The group to link to.
function M.default_highlight(group, link)
  if not H.highlights[group] then
    H.highlights[group] = link
  end
  if vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = group })) then
    vim.api.nvim_set_hl(0, group, { link = link })
  end
end

vim.api.nvim_create_autocmd("Colorscheme", {
  group = vim.api.nvim_create_augroup("Contour", { clear = false }),
  callback = function()
    for from, to in pairs(H.highlights) do
      M.default_highlight(from, to)
    end
  end,
})

--- Creates a rendering context based on the current nvim state.
--- @param scope "global"|"window"
--- @return Contour.Context
function M.make_context(scope)
  local context = {}
  context.win = scope == "global" and curwin() or vim.g.statusline_winid
  context.buf = winbuf(context.win)
  context.tab = curtab()
  context.current = context.win == curwin()
  context.width = scope == "window" and winwid(context.win) or vim.o.columns
  return context
end

--- Prints an error message for a module.
function M.error(module, msg)
  vim.notify("nvim-contour " .. module .. ":\n    " .. msg:gsub("\n", "\n    "), vim.log.levels.ERROR)
end

--- Prints an error messsage for a module one time.
function M.error_once(module, msg)
  vim.notify_once("nvim-contour " .. module .. ":\n    " .. msg:gsub("\n", "\n    "), vim.log.levels.ERROR)
end

function M.warn_once(module, msg)
  vim.notify_once("nvim-contour " .. module .. ":\n    " .. msg:gsub("\n", "\n    "), vim.log.levels.WARN)
end

return M
