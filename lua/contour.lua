-- simirian's NeoVim contour
-- root module

local components = require("contour.components")
local util = require("contour.util")
local vfn = vim.fn
local api = vim.api

local H = {}
local M = {}

--- A item that represetns a contour component.
--- @class Contour.CompSpec: { [string]: any }
--- The component name.
--- @field component string

--- An item that contour can render.
--- @class Contour.Item string|Contour.Group|Contour.ComSpec|fun(): string

--- Renders a statusline item.
--- @param item Contour.Item The item to render.
--- @return string statusline
function H.makeitem(item)
  if type(item) == "function" then
    return item()
  elseif type(item) == "table" then
    if type(item.component) == "string" then
      local component = components[item.component]
      if not component then
        util.error("contour", "Unknown componnet in config: " .. item.component
          .. ". It will be replaced with an empty string.")
        return ""
      else
        return component.render(setmetatable(item, {
          __index = component.defaults
        }))
      end
    else
      return H.makegroup(item --[[ @as Contour.Group ]])
    end
  else
    return item --[[ @as string ]]
  end
end

--- A group of contour items.
--- @class Contour.Group: Contour.Item[]
--- If the group should be left aligned.
--- @field left boolean
--- The minimum width to render the group at.
--- @field min_width integer
--- The max width to render the group at.
--- @field max_width integer
--- The groups highlight group name.
--- @field highlight string

--- Renders a group string out of a group table.
--- @param group Contour.Group The group to render.
--- @return string statusline
function H.makegroup(group)
  local str = ""
  local ig = (group.left or group.min_width or group.max_width)
      and true or false
  if ig then str = str .. "%" end
  if group.left then str = str .. "-" end
  if group.min_width then str = str .. group.min_width end
  if group.max_width then str = str .. "." .. group.max_width end
  if ig then str = str .. "(" end
  local hl = util.highlight(group.highlight)
  str = str .. hl
  for _, item in ipairs(group) do str = str .. H.makeitem(item) .. hl end
  return str .. ((group.left or group.min_width or group.max_width) and "%)")
end

--- Function cache. DO NOT EDIT MANUALLY!!!
--- @type { [string]: fun(): string }
M._f = {}

--- A contour line specification.
--- @class Contour.LineSpec: Contour.Item[]
--- The default highlight of the line.
--- @field highlight string

--- Makes a statusline out of a line spec.
--- @param linespec Contour.LineSpec The line spec.
--- @return string statusline
function H.makeline(linespec)
  -- function that renders the line
  local function fn()
    local hl = util.highlight(linespec.highlight)
    local line = hl
    for _, item in ipairs(linespec) do line = line .. H.makeitem(item) .. hl end
    return line
  end
  -- put the function in the cache, and return the statusline string
  local str = "%{%v:lua.require'contour'._f.f"
  local nr = 1
  for _, v in pairs(M._f) do
    if v == fn then return str .. nr .. "()%}" end
    nr = nr + 1
  end
  M._f["f" .. nr] = fn
  return str .. nr .. "()%}"
end

--- Options for contour.
--- @class Contour.Opts: { [string]: table }
--- How the statusline should be shown.
--- @field show_statusline? "never"|"multiple"|"always"|"global"
--- How the tabline should be shown.
--- @field show_tabline? "never"|"multiple"|"always"
--- The statusline.
--- @field statusline? Contour.LineSpec
--- The wimbar.
--- @field winbar? Contour.LineSpec
--- The Tabline.
--- @field tabline? Contour.LineSpec
M.defaults = {
  show_statusline = "always",
  show_tabline = "always",
}

--- Sets up the statusline, tabline, and winbar when given line specs.
--- @param opts Contour.Opts
function M.setup(opts)
  opts = opts or {}
  -- set up components
  local modules =
      api.nvim_get_runtime_file("lua/contour/components/*.lua", true)
  for _, fname in ipairs(modules) do
    local name = vfn.fnamemodify(fname, ":t:r")
    if opts[name] then
      require("contour.components." .. name).setup(opts[name])
    end
  end

  -- set options
  if opts.show_statusline then
    vim.o.laststatus = ({ -- switch expression
      never = 0,
      multiple = 1,
      always = 2,
      global = 3,
    })[opts.show_statusline]
  end
  if opts.show_tabline then
    vim.o.showtabline = ({ -- switch expression
      never = 0,
      multiple = 1,
      always = 2,
    })[opts.show_tabline]
  end
  -- load lines
  if opts.statusline then vim.o.statusline = H.makeline(opts.statusline) end
  if opts.winbar then vim.o.winbar = H.makeline(opts.winbar) end
  if opts.tabline then vim.o.tabline = H.makeline(opts.tabline) end
end

--- Refreshes the statusline, winbar, and tabline.
function M.refresh()
  vim.cmd("redrawstatus!")
  vim.cmd("redrawtabline!")
end

return M
