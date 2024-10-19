-- simirian's NeoVim contour
-- raw statusline string component

local eval_statusline = vim.api.nvim_eval_statusline
local highlight = require("contour.util").highlight
local tbl_insert = table.insert

local H = {}
local M = {}

--- Evaluates and inteligently escapes a statusline string.
--- @class Contour.Raw
--- @field [1] "raw"
--- The statusline string to evaluate.
--- @field item? string
H.defaults = {
  "raw",
  item = nil,
  width = 0,
}

--- @type Contour.Raw
H.config = setmetatable({}, { __index = H.defaults })

--- Evaluates and converts the raw statusline to contour's internal format.
--- @param opts Contour.Raw The options to use for rendering.
--- @param context Contour.Context The context to render in.
function M.render(opts, context)
  setmetatable(opts or {}, { __index = H.config })
  local max_width = context.width
  if opts.width ~= 0 and opts.width < context.width then
    max_width = opts.width
  end
  local info = eval_statusline(opts.item, {
    winid = context.win,
    highlights = true,
    maxwidth = max_width,
  })
  local line = {}
  for i, hl in ipairs(info.highlights) do
    local hlend = info.highlights[i + 1] and info.highlights[i + 1].start or #info.str
    tbl_insert(line, highlight(hl.group))
    tbl_insert(line, info.str:sub(hl.start + 1, hlend))
  end
  return line
end

--- This is kinda useless, but it sets the default raw component options.
--- @param opts Contour.Raw The default options.
function M.setup(opts)
  H.config = setmetatable(opts or {}, { __index = H.defaults })
end

return M
