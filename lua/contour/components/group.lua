-- simirian's NeoVim contour
-- group component

local strwidth = vim.fn.strwidth
local list_reverse = vim.fn.reverse
local tbl_insert = table.insert
local iter = vim.iter
local get_component = require("contour.components").get
local highlight = require("contour.util").highlight

local H = {}
local M = {}

--- Component that can include multiple other components.
--- @class Contour.Group
--- @field [1] "group"
--- Which side to trim from and to place whitespace after.
--- @field trim? "left"|"right"
--- The maximum width of the group. If 0, then no max width will be assumed
--- @field width? integer
--- The items that this group should render.
--- @field items? Contour.Component[]
--- The highlight for the group.
--- @field highlight? string|false
H.defaults = {
  "group",
  trim = "right",
  width = 0,
  items = {},
  highlight = false,
}

--- @type Contour.Group
H.config = setmetatable({}, { __index = H.defaults })

--- Renders a group of items specified in opts under the given context.
--- @param opts Contour.Group The group options.
--- @param context Contour.Context The Context to render in.
--- @return Contour.Primitive[] line
function M.render(opts, context)
  opts = setmetatable(opts, { __index = H.config })
  local line = {}
  local width = 0
  local target_width = context.width
  if opts.width ~= 0 and opts.width < context.width then
    target_width = opts.width
  end

  local items = opts.items
  if opts.trim == "left" then
    items = list_reverse(items)
  end

  for _, item in ipairs(items) do
    local component = get_component(item[1])
    if component then
      local rendered = component.render(item, context)

      local iwidth = 0
      for _, section in ipairs(rendered) do
        if type(section) == "string" then
          iwidth = iwidth + strwidth(section)
        end
      end
      width = width + iwidth

      if width > target_width then break end
      tbl_insert(line, rendered)
    end
  end

  local hlfn = highlight(opts.highlight)
  tbl_insert(line, { (" "):rep(target_width - width) })
  line = iter(line)
  if hlfn then
    line:map(function(e)
      tbl_insert(e, 1, hlfn)
      return e
    end)
  end
  if opts.trim == "left" then
    line = line:rev()
  end
  return line:flatten():totable()
end

--- Sets up the default config for contour groups.
--- @param opts Contour.Group The options to use.
function M.setup(opts)
  H.config = setmetatable(opts or {}, { __index = H.defaults })
end

return M
