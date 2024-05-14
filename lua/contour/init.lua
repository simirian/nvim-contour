-- simirian's NeoVim contour
-- root module

local o = vim.go
local c = require("contour.components")
local f = require("contour.functions")

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
        return f.fncomponent(item._render)
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
    return f.fncomponent(item)
  else
    return item
  end
end

---Converts a contour group to a statusline string.
---@param group table The group to convert.
---@return string statusline
function H.gengroup(group)
  local str = "%"
  local hl = group.highlight and c.Highlight(group.highlight) or ""
  -- set left alignment
  if group.left then str = str .. "-" end
  -- set min width
  if group.min_width then str = str .. group.min_width end
  -- set max width
  if group.max_width then str = str .. "." .. group.max_width end
  -- add highlight
  str = str .. hl
  -- start group
  str = str .. "("
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
  local hl = (line.highlight and c.Highlight(line.highlight) or "")
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

function M.statusline.setup(opts)
  o.laststatus = opts.mode
  o.statusline = H.genline(opts[1])
end

function M.statusline.refresh()
  vim.cmd("redrawstatus!")
end

function M.winbar.setup(opts)
  o.winbar = H.genline(opts[1])
end

function M.winbar.refresh()
  vim.cmd("redrawstatus!")
end

function M.tabline.setup(opts)
  o.showtabline = opts.mode
  o.tabline = H.genline(opts[1])
end

return M
