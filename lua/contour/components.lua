-- simirian's NeoVim contour
-- components module

--- components module
local M = {
  --- @type Contour.Buffer? Buffer class
  buffer = nil,
  --- @type Contour.BufList? BufList class.
  buflist = nil,
  --- @type TabList? TabList class.
  tablist = nil,
  --- @type TabBufs? TabBufs class.
  tabbufs = nil,
}

--- Base class for any component.
--- @class Contour.Component
--- The class defaults.
--- @field defaults { [string]: any }
--- This function uses scopes to create a function with no arguments that
--- renders the component with the given arguments.
--- @field new fun(opts: any): fun(): string
--- This fucnton sets the default values of the component.
--- @field setup fun(opts: any): string

--- Initialises a new component module. All you need to do to create a valid
--- component with this is puplically expose the returned table, and give it a
--- render function which takes the component's options as its only argument.
--- @param defaults { [string]: any } The default render() arguments.
--- @return Contour.Component component
function M.create(defaults)
  local component = {
    defaults = setmetatable({}, { __index = defaults })
  }

  function component:__call(...) return self.new(...) end

  function component.new(opts)
    local lopts = setmetatable(opts or {}, { __index = component.defaults })
    return function() return component.render(lopts) end
  end

  function component.setup(opts)
    component.defaults = setmetatable(
      vim.tbl_deep_extend("force", component.defaults, opts or {}),
      { __index = defaults }
    )
  end

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

-- lazy require submodules through this one
setmetatable(M, {
  __index = function(tbl, key)
    local exists, component = pcall(require, "contour." .. key)
    if not exists then
      vim.notify("contour: nonexistant component: " .. key,
        vim.log.levels.ERROR)
      return
    end
    tbl[key] = component
    return component
  end,
})

return M
