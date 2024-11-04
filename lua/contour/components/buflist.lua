-- simirian's NeoVim contour
-- buffer list component

local buffer = require("contour.components.buffer")

local bufrender = buffer.render
local buflisted = vim.fn.buflisted
local bufloaded = vim.fn.bufloaded
local list_bufs = vim.api.nvim_list_bufs
local current_buf = vim.api.nvim_get_current_buf
local copy = vim.deepcopy
local list_extend = vim.list_extend

local H = {}
local M = {}

--- Renders a list of buffers according to a filter function.
--- @class Contour.Buflist
--- @field [1] "buflist"
--- The filter function to decide which buffers to render.
--- @field filter? fun(integer): boolean
--- The options for rendering the buffers.
--- @field buffer? Contour.Buffer
--- Highlight for current buffer.
--- @field highlight_norm? string|false
--- Highlight for non-current buffers.
--- @field highlight_sel? string|false
H.defaults = {
  "buflist",
  filter = function(bufnr)
    return buflisted(bufnr) == 1 and bufloaded(bufnr) == 1
  end,

  buffer = { "buffer" },

  highlight_norm = "TabLine",
  highlight_sel = "TabLineSel",
}

--- @type Contour.Buflist
H.config = setmetatable({}, { __index = H.defaults })

--- Renders the tab list in context with the given options.
--- @param opts Contour.Buflist The options to render with.
--- @param context Contour.Context The context to render in.
--- @return Contour.Primitive[] line
function M.render(opts, context)
  opts = setmetatable(opts or {}, { __index = H.config })
  local line = {}

  local bopts = copy(opts.buffer or {})
  bopts.highlight_norm = opts.highlight_norm
  bopts.highlight_sel = opts.highlight_sel

  for _, bufnr in ipairs(list_bufs()) do
    if opts.filter(bufnr) then
      local current = current_buf() == bufnr
      local bctx = copy(context)
      bctx.current = current
      bctx.buf = bufnr
      list_extend(line, bufrender(bopts, bctx))
    end
  end

  return line
end

--- Sets up the default buffer list options
--- @param opts Contour.Buflist The options to set as default.
function M.setup(opts)
  H.config = setmetatable(opts or {}, { __index = H.defaults })
end

return M
