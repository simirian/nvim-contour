-- simirian's NeoVim contour
-- function component

local H = {}
local M = {}

--- Renders according to a function's output.
--- @class Contour.Function
--- @field [1] "function"
--- @field f fun(data: table, context: Contour.Context): Contour.Primitive[]
H.default = {
  "function",
  f = function() return {} end,
}

--- Renders the functions in the component.
--- @param opts Contour.Function The component to render.
--- @param context Contour.Context The context to render in.
--- @return Contour.Primitive[] line
function M.render(opts, context)
  opts = opts or {}
  local f = opts.f or H.default.f
  return f and f(opts, context) or {}
end

return M
