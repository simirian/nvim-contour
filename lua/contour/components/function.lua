-- simirian's NeoVim contour
-- function component

local H = {}
local M = {}

--- Renders according to a function's output.
--- @class Contour.Function
--- @field [1] "function"
--- @field fn? fun(data: table, context: Contour.Context): Contour.Primitive[]
H.default = {
  "function",
  fn = nil,
}

--- @type Contour.Function
H.config = setmetatable({}, { __index = H.default })

--- Renders the functions in the component.
--- @param opts Contour.Function The component to render.
--- @param context Contour.Context The context to render in.
--- @return Contour.Primitive[] line
function M.render(opts, context)
  opts = setmetatable(opts or {}, { __index = H.config })
  if opts.fn then return opts.fn(opts, context) end
  return {}
end

--- Configures the defaults for the function module.
--- @param opts Contour.Function The config options.
function M.setup(opts)
  H.config = setmetatable(opts or {}, { __index = H.default })
end

return M
