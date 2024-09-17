-- simirian's NeoVim contour
-- buffer list component class

local vfn = vim.fn
local buf = require("contour.components.buffer")
local util = require("contour.util")

local H = {}

--- Options to control the BufList component's rendering.
--- @class Contour.BufList.Opts: Contour.Buffer.Opts
--- Which (among ALL) buffers to include in the list.
--- @field filter? fun(bufnr: integer): boolean
H.defaults = setmetatable({
  highlight = "TabLine",
  highlight_sel = "TabLineSel",
}, { __index = buf.defaults })

--- Determines if a buffer should be included in the buflist.
--- @param bufnr integer The buffer to decide upon rendering
--- @reutrn boolean include
function H.defaults.filter(bufnr)
  local bi = vfn.getbufinfo(bufnr)[1]
  return bi.listed == 1 and bi.loaded == 1
end

--- @class Contour.BufList: Contour.Component
local M = util.component(H.defaults)

M.render_buffer = buf.render_buffer

--- Renders a list of all buffers, which can be filtered by the options.
--- @param opts Contour.BufList.Opts The rendering options.
--- @return string statusline
function M.render(opts)
  local str = ""
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if opts.filter(bufnr) then
      str = str .. M.render_buffer(opts, bufnr)
    end
  end
  return str
end

return M
