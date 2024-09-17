-- simirian's NeoVim contour
-- utility functions

local H = {}
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

--- Creates a component from the given defaults table.
--- @param defaults table The defaults provided
--- @return Contour.Component component
function M.component(defaults)
  if not defaults then
    M.error("contour.util", "Tried to create a component with no defaults.\n"
      .. "If you do not want defaults, provide an empty table.")
    return {}
  end
  local component = {}
  component.defaults = setmetatable({}, { __index = defaults })

  function component.setup(opts)
    for key, value in pairs(opts) do
      component.defaults[key] = value
    end
  end

  return component
end

--- Creates a highlighting statusline string for the given group.
--- @param group? string|number The group's name or `User#` group's number.
--- Several cases for the group are as follows:
---   nil: no change in highlighting
---   "": reset highlighting
---   number: set highlighting to that user highlight
---   string: set highlight to that group
--- @return string statusline
function M.highlight(group)
  if not group then return "" end
  if group == "" then return "%*" end
  if type(group) == "number" then return "%" .. group .. "*" end
  if type(group) == "string" then return "%#" .. group .. "#" end
  M.error("contour.util",
    "Tried to set highlight with a non number/string value.")
  return ""
end

--- Prints an error message from the given module.
--- @param module string The module name to use.
--- @param message string The message to print.
function M.error(module, message)
  vim.notify(module .. "\n    " .. message:gsub("\n", "\n    "),
    vim.log.levels.ERROR)
end

H._errors = {}

--- Prints an error message from the given module.
--- @param module string The module name to use.
--- @param message string The message to print.
function M.error_once(module, message)
  if H._errors[module .. message] then return end
  H._errors[module .. message] = true
  vim.notify(module .. "\n    " .. message:gsub("\n", "\n    "),
    vim.log.levels.ERROR)
end

return M
