-- simirian's NeoVim contour
-- space component

local util = require("contour.util")

local tbl_insert = table.insert
local scopy = vim.fn.copy
local strwidth = vim.fn.strwidth
local floor = math.floor
local ceil = math.ceil
local list_extend = vim.list_extend
local get_component = require("contour.components").get
local highlight = util.highlight

local H = {}
local M = {}

--- @class Contour.Space
--- The maximum width to display items in. Assumes that 0 means infinite.
--- @field width integer
--- The items to display. If any item is not valid for some reason, then it is
--- not counted. ie. two valid and one invalid item counts as two items. If
--- there are more than three items their validity will not be tested and there
--- will be an error notification.
--- 1. centers a single item
--- 2. splits two items to be left and right aligned
--- 3. splits the items to be left, then right, then center aligned
--- @field items Contour.Component[]
--- The highlight to use for the component.
--- @field highlight string|false
H.defaults = {
  width = 0,
  items = {},
  highlight = false,
}

--- @type Contour.Space
H.config = setmetatable({}, { __index = H.defaults })

--- Determines the length of a rendered item.
--- @param item? { opts: Contour.Component, mod: Contour.ComponentModule, rendered: Contour.Primitive[] } The item to find the length of.
--- @return integer length
function H.itemlength(item)
  if not item then return 0 end
  local len = 0
  for _, section in ipairs(item.rendered) do
    if type(section) == "string" then
      len = len + strwidth(section)
    end
  end
  return len
end

--- Renders a spacing group of up to three components.
--- @param opts Contour.Space The options to use for rendering.
--- @param context Contour.Context The context to render in.
--- @return Contour.Primitive[] line
function M.render(opts, context)
  if opts._invalid then return {} end
  if #opts.items > 3 then
    util.error("space", "Tried to create a space group with more than three items.\n" .. vim.inspect(opts))
    --- @diagnostic disable-next-line: inject-field This prevents lockups from endless notifications.
    opts._invalid = true
    return {}
  end

  opts = setmetatable(opts or {}, { __index = H.config })

  --- @type { opts: Contour.Component, mod: Contour.ComponentModule, [any]: any }[]
  local items = {}
  for _, item in ipairs(opts.items) do
    local component = get_component(item[1])
    if component then
      tbl_insert(items, {
        opts = item,
        mod = component
      })
    end
  end

  local target_width = context.width
  if opts.width ~= 0 and opts.width < context.width then
    target_width = opts.width
  end

  local left, center, right
  if #items == 1 then
    center = items[1]
    center.rendered = center.mod.render(center.opts, context)
  elseif #items == 2 then
    local lctx = scopy(context)
    lctx.width = ceil(target_width / 2)
    local rctx = scopy(context)
    rctx.width = floor(target_width / 2)

    left = items[1]
    left.rendered = left.mod.render(left.opts, lctx)
    right = items[2]
    right.rendered = right.mod.render(right.opts, rctx)
  else -- #items == 3
    local ectx = scopy(context)
    ectx.width = floor(target_width / 3) + (target_width % 3 == 2 and 1 or 0)
    local cctx = scopy(context)
    cctx.width = floor(target_width / 3) + (target_width % 3 == 1 and 1 or 0)

    left = items[1]
    left.rendered = left.mod.render(left.opts, ectx)
    center = items[2]
    center.rendered = center.mod.render(center.opts, cctx)
    right = items[3]
    right.rendered = right.mod.render(right.opts, ectx)
  end

  local lwidth = H.itemlength(left) + ceil(H.itemlength(center) / 2)
  local rwidth = H.itemlength(right) + floor(H.itemlength(center) / 2)
  local lspace = (" "):rep(ceil(target_width / 2) - lwidth)
  local rspace = (" "):rep(floor(target_width / 2) - rwidth)

  local hlfn = highlight(opts.highlight)
  local line = {}
  tbl_insert(line, hlfn)
  tbl_insert(line, left and left.rendered or nil)
  tbl_insert(line, hlfn)
  tbl_insert(line, lspace)
  tbl_insert(line, center and center.rendered or nil)
  tbl_insert(line, hlfn)
  tbl_insert(line, rspace)
  tbl_insert(line, right and right.rendered or nil)
  return vim.iter(line):flatten():totable()
end

--- Sets up the contour space group defaults.
--- @param opts Contour.Space The options to use as defaults.
function M.setup(opts)
  H.config = setmetatable(opts or {}, { __index = H.defaults })
end

return M
