-- simirian's NeoVim contour
-- root module

local o = vim.opt
local comp = require("contour.components")
local fns = require("contour.functions")

local H = {}

--- Generates a statusline string from a contour item.
--- Can take a contour component, a contour group, or a string function.
--- @param item string|table|fun(): string the item to convert
--- @return string statusline
function H.genitem(item)
  if type(item) == "table" then
    -- could be a group of a component
    if item._render then
      -- this has to be a component
      if type(item._render) == "function" then
        -- if render is a function then we generate its component
        return fns.fncomponent(item._render)
      else
        -- otherwise we assume it's a pregenerated string and use it directly
        return item._render
      end
    else
      -- group, so we generate its string
      return H.gengroup(item)
    end
  elseif type(item) == "function" then
    -- need to make a function component
    return fns.fncomponent(item)
  else
    return item
  end
end

---Converts a contour group to a statusline string.
---@param group table The group to convert.
---@return string statusline
function H.gengroup(group)
  local str = "%"
  -- set left alignment
  if group.left then str = str .. "-" end
  -- set min width
  if group.min_width then str = str .. group.min_width end
  -- set max width
  if group.max_width then str = str .. "." .. group.max_width end
  -- start group
  str = str .. "("
  -- add highlight
  local hl = group.highlight and comp.highlight(group.highlight) or ""
  str = str .. hl
  -- add all the items
  for _, item in ipairs(group) do str = str .. H.genitem(item) .. hl end
  -- close the group
  return str .. "%)"
end

--- Generates a statusline based on a line specification.
--- The specification should be a list of items, with an optional
---   highlight key for the default highlight.
--- @param line table
--- @return string statusline
function H.genline(line)
  local str = ""
  -- add highlight
  local hl = (line.highlight and comp.highlight(line.highlight) or "")
  str = str .. hl
  -- add all the items
  for _, item in ipairs(line) do str = str .. H.genitem(item) .. hl end
  --reset highlight
  if line.highlight then str = str .. "%0*" end
  return str
end

local M = {
  statusline = {},
  winbar = {},
  tabline = {},
}

--- Sets up the statusline.
--- @param display "never"|"multiple"|"always"|"global" How to show the statusline.
--- @param line table The statusline spec.
function M.statusline.setup(display, line)
  local displays = {
    never = 0,
    multiple = 1,
    always = 2,
    global = 3,
  }
  o.laststatus = displays[display]
  o.statusline = H.genline(line)
end

--- Refreshes the statusline and winbar.
function M.statusline.refresh()
  vim.cmd("redrawstatus!")
end

--- Sets up the winbar.
--- @param line table The winbar spec.
function M.winbar.setup(line)
  o.winbar = H.genline(line)
end

--- Refreshes the winbar and statusline.
function M.winbar.refresh()
  vim.cmd("redrawstatus!")
end

--- Sets up the tabline.
--- @param display "never"|"multiple"|"always" When to show the tabline.
--- @param line table The tabline spec.
function M.tabline.setup(display, line)
  local displays = {
    never = 0,
    multiple = 1,
    always = 2,
  }
  o.showtabline = displays[display]
  o.tabline = H.genline(line)
end

--- Refreshes the tabline.
function M.tabline.refresh()
  vim.cmd("redrawtabline!")
end

return M
