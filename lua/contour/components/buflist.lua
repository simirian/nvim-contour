-- simirian's NeoVim contour
-- buffer list component

local buffer = require("contour.components.buffer")
local util = require("contour.util")

local buflisted = vim.fn.buflisted
local bufloaded = vim.fn.bufloaded
local list_bufs = vim.api.nvim_list_bufs
local current_buf = vim.api.nvim_get_current_buf
local copy = vim.deepcopy
local list_extend = vim.list_extend
local tbl_deep_extend = vim.tbl_deep_extend

local H = {}
local M = {}

--- Renders a list of buffers according to a filter function.
--- @class Contour.Buflist
--- @field [1] "buflist"
--- The filter function to decide which buffers to render.
--- @field filter? fun(integer): boolean
--- The options for rendering the buffers.
--- @field buffer? Contour.Buffer
H.defaults = {
  "buflist",
  filter = function(bufnr)
    return buflisted(bufnr) == 1 and bufloaded(bufnr) == 1
  end,

  buffer = {
    "buffer",
    highlight_norm = "ContourBuflistNorm",
    highlight_sel = "ContourBuflistSel",
  },
}

util.default_highlight("ContourBuflistNorm", "TabLine")
util.default_highlight("ContourBuflistSel", "TabLineSel")

--- Renders the tab list in context with the given options.
--- @param opts Contour.Buflist The options to render with.
--- @param context Contour.Context The context to render in.
--- @return Contour.Primitive[] line
function M.render(opts, context)
  opts = tbl_deep_extend("keep", opts or {}, H.defaults)
  local line = {}
  local curbuf = current_buf()
  local ctx = copy(context)

  for _, bufnr in ipairs(list_bufs()) do
    if opts.filter(bufnr) then
      ctx.buf = bufnr
      ctx.current = bufnr == curbuf
      list_extend(line, buffer.render(opts.buffer, ctx))
    end
    -- TODO: truncation
  end

  return line
end

return M
