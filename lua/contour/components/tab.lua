-- simirian's NeoVim contour
-- tab component

local util = require("contour.util")

local highlight = require("contour.util").highlight
local render_buflist = require("contour.components.buflist").render
local list_extend = vim.list_extend
local tbl_insert = table.insert
local tbl_contains = vim.tbl_contains
local copy = vim.deepcopy
local curtab = vim.api.nvim_get_current_tabpage
local buflisted = vim.fn.buflisted
local tabbufs = vim.fn.tabpagebuflist
local bo = vim.bo

local H = {}
local M = {}

--- @alias Contour.Tab.Item
--- | `"number"`
--- | `"buflist"`
--- | `"modified"`

--- Renders a single tab.
--- @class Contour.Tab
--- @field [1] "tablist"
--- The items to draw in the tab.
--- @field items? Contour.Tab.Item[]
--- The icon to use to show the tab has modified buffers.
--- @field modified_icon? string
--- The formatting for the "buflist" item.
--- @field buflist? Contour.Buflist
--- The highlighting for non-selected tabs.
--- @field highlight_norm? string|false
--- The highlighting for selected tabs.
--- @field highlight_sel? string|false
--- The highlighting for the current buffer in the buflist item.
--- @field highlight_buf_sel? string|false
H.defaults = {
  "tablist",
  items = {
    "number",
    "modified",
  },
  modified_icon = "*",

  buflist = {
    "buflist",
    buffer = {
      items = { "typeicon", "filename" },
    },
  },

  highlight_norm = "ContourTabNorm",
  highlight_sel = "ContourTabSel",
  highlight_buf_sel = "ContourTabBufSel",
}

util.default_highlight("ContourTabNorm", "TabLine")
util.default_highlight("ContourTabSel", "TabLineSel")
util.default_highlight("ContourTabBufSel", "TabLineSel")

--- @type Contour.Tab
H.config = setmetatable({}, { __index = H.defaults })

--- Renders the tab list in context with the given options.
--- @param opts Contour.Tab The options to render with.
--- @param context Contour.Context The context to render in.
--- @return Contour.Primitive[] line
function M.render(opts, context)
  opts = setmetatable(opts or {}, { __index = H.config })
  local line = {}
  local current = context.current ~= nil and context.current or curtab()
  local hlstr = current and opts.highlight_sel or opts.highlight_norm
  tbl_insert(line, highlight(hlstr))

  for _, item in ipairs(opts.items) do
    if item == "number" then
      tbl_insert(line, " " .. context.tab .. " ")
    elseif item == "buflist" then
      local blopts = copy(opts.buflist or {})
      blopts.highlight_norm = hlstr
      blopts.highlight_sel = opts.highlight_buf_sel
      blopts.filter = function(bufnr)
        return buflisted(bufnr) == 1 and tbl_contains(tabbufs(context.tab), bufnr)
      end
      list_extend(line, render_buflist(blopts, context))
    elseif item == "modified" then
      local modified = false
      for _, bufnr in ipairs(tabbufs(context.tab)) do
        if bo[bufnr].modified and buflisted(bufnr) == 1 then
          modified = true
          break
        end
      end
      if modified then
        tbl_insert(line, " " .. opts.modified_icon .. " ")
      end
    end
  end

  return line
end

--- Sets the default tablist options.
--- @param opts Contour.Tab The options to make default.
function M.setup(opts)
  H.config = setmetatable(opts or {}, { __index = H.defaults })
end

return M
