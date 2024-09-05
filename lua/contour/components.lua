-- simirian's NeoVim contour
-- components module

local M = {}

--- Base class for any component.
--- @class Contour.Component
--- The class defaults.
--- @field defaults { [string]: any }
--- This function uses scopes to create a function with no arguments that
--- renders the component with the given arguments.
--- @field call fun(opts: { [string]: any }): fun(): string
--- This function returns the component table for this component.
--- @field new fun(opts: { [string]: any }): table
--- This fucnton sets the default values of the component.
--- @field setup fun(opts: { [string]: any }): string

--- List of existing components.
--- @type { [string]: Contour.Component }
M.list = setmetatable({}, {
  __index = function(tbl, key)
    local ok, comp = pcall(require, "contour." .. key)
    if not ok then return nil end
    tbl[key] = comp
    return comp
  end
})

--- Initialises a new component module. All you need to do to create a valid
--- component with this is puplically expose the returned table, and give it a
--- render function which takes the component's options as its only argument.
--- @param defaults { [string]: any } The default render() arguments.
--- @param name string The name of this component, used for literal table setup.
--- @return Contour.Component component
function M.create(defaults, name)
  local component = {
    defaults = setmetatable({}, { __index = defaults })
  }

  function component.call(opts)
    local lopts = setmetatable(opts or {}, { __index = component.defaults })
    return function() return component.render(lopts) end
  end

  function component.new(opts)
    opts = opts or {}
    opts.component = name
    return opts
  end

  function component.setup(opts)
    component.defaults = setmetatable(
      vim.tbl_deep_extend("force", component.defaults, opts or {}),
      { __index = defaults }
    )
  end

  if name then M.list[name] = component end
  return setmetatable(component, component)
end

--- Converts a highlight group name or number into a statusline highlight group.
--- @param group? string Highlight group.
--- @return string statusline
function M.highlight(group)
  if not group then return "" end     -- no change
  if group == "" then return "%*" end -- reset
  return "%#" .. group .. "#"         -- set to group
end

return M
