-- simirian's NeoVim contour
-- components module

--- A component must have a ._render() function that can be detected by the base
--- module to store and use a working function reference.
---
--- This function expects to also find a :render() function it can call.
--- @class Component
--- @field _render fun(): string

--- components module
local M = {
  --- @type Buffer? Buffer class
  buffer = nil,
  --- @type BufList? BufList class.
  buflist = nil,
  --- @type TabList? TabList class.
  tablist = nil,
  --- @type TabBufs? TabBufs class.
  tabbufs = nil,
}

--- A highlight specification for the highlight function.
--- @alias chl string|number

--- Converts a highlight group name or number into a statusline highlight group.
--- @param group? chl Highlight group or user group number.
--- @return string statusline
function M.highlight(group)
  -- reset highlight to TabLine
  if not group then return "%0*" end
  -- set highlight to User{group}
  if type(group) == "number" then return "%" .. group .. "*" end
  -- with nothing we skip making a highlight
  if group == "" then return "" end
  -- set highlight to any other group
  return "%#" .. group .. "#"
end

--- Takes a component and sets it's metatable, optinally taking a parent
--- component class as well.
--- @generic T
--- @param table T The table to make into component class.
--- @param parent? Component The parent component class.
--- @return T component
function M.apply_metatable(table, parent)
  parent = parent or nil
  local metatable = {
    __call = function(tbl, args)
      args = args or {}
      setmetatable(args, { __index = tbl })
      -- this function will be registered with the functions module
      function args._render()
        return args:render()
      end

      return args
    end,
    __index = parent,
  }
  return setmetatable(table, metatable)
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
