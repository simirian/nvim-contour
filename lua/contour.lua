-- simirian's NeoVim contour
-- root module

local util = require("contour.util")
local components = require("contour.components")

local make_context = util.make_context
local get_component = components.get

local H = {}
local M = {}

H.augroup = vim.api.nvim_create_augroup("Contour", { clear = false })

--- @alias Contour.Primitive
--- | fun(): string
--- | string
--- | nil

M._f = {}
H.cache = {
  statusline = {},
  winbar = {},
  tabline = {},
}

--- Takes a line spec and the line it is for and returns the statusline string
--- for that buffer.
--- @param line "tabline"|"statusline"|"winbar" The line to render the item for.
--- @param spec Contour.Component The line spec.
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

--- Sets up a line of a given type for a given filetype.
--- @param line "statusline"|"winbar"|"tabline" The type of line.
--- @param ft string|string[] The filetypes to activate on.
--- @param spec Contour.Component The line spec.
function H.setup_line(line, ft, spec)
  H.cache[line][ft] = H.makeline("statusline", spec)
  if ft == "default" then
    vim.o[line] = H.cache[line][ft]
  else
    vim.api.nvim_create_autocmd("FileType", {
      group = H.augroup,
      pattern = ft,
      callback = function()
        vim.wo[line] = H.cache[line][ft]
      end
    })
  end
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
  for ft, spec in pairs(opts.statusline) do
    H.setup_line("statusline", ft, spec)
  end

  opts.winbar = opts.winbar or {}
  for ft, spec in pairs(opts.winbar) do
    H.setup_line("winbar", ft, spec)
  end

  opts.tabline = opts.tabline or {}
  for ft, spec in pairs(opts.tabline) do
    H.setup_line("tabline", ft, spec)
  end
end

return M
