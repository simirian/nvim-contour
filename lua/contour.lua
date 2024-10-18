-- simirian's NeoVim contour
-- root module

local util = require("contour.util")
local components = require("contour.components")

local make_context = util.make_context
local get_component = components.get

local H = {}
local M = {}

--- @alias Contour.Primitive
--- | fun(): string
--- | string
--- | nil

M._f = {}

--- Takes a line spec and the line it is for and returns the statusline string
--- for that buffer.
--- @param line "tabline"|"statusline"|"winbar" The line to render the item for.
--- @param spec table The line spec.
--- @return string statusline
function H.makeline(line, spec)
  local i = 1
  while M._f["f" .. i] do
    i = i + 1
  end

  M._f["f" .. i] = function()
    local scope = "window"
    if line == "tabline" or line == "statusline" and vim.o.laststatus == 3 then
      scope = "global"
    end

    local context = make_context(scope)
    local component = get_component(spec[1])
    if component then
      local str = ""
      local primlist = component.render(spec, context)
      for _, prim in ipairs(primlist) do
        if type(prim) == "string" then str = str .. prim:gsub("%%", "%%%%") end
        if type(prim) == "function" then str = str .. prim() end
      end
      return str
    else
      return ""
    end
  end

  return "%!v:lua.require'contour'._f.f" .. i .. "()"
end

function M.setup(opts)
  opts = opts or {}

  local clist = components.list()
  for _, component in ipairs(clist) do
    if opts[component] then
      components.get(component).setup(opts[component])
    end
  end

  opts.statusline = opts.statusline or {}
  for ft, line in pairs(opts.statusline) do
    if ft == "default" then
      vim.o.statusline = H.makeline("statusline", line)
    else
      vim.print(":set statusline ft=", ft) -- STUB
    end
  end

  opts.winbar = opts.winbar or {}
  for ft, line in pairs(opts.winbar) do
    if ft == "default" then
      print(":set winbar")             -- STUB
    else
      vim.print(":set winbar ft=", ft) -- STUB
    end
  end

  opts.tabline = opts.tabline or {}
  for ft, line in pairs(opts.tabline) do
    if ft == "default" then
      print(":set tabline")             -- STUB
    else
      vim.print(":set tabline ft=", ft) -- STUB
    end
  end
end

return M
