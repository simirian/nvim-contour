-- simirian's NeoVim contour
-- buffer component

local util = require("contour.util")

local fnamemodify = vim.fn.fnamemodify
local bufname = vim.fn.bufname
local highlight = util.highlight
local tbl_insert = table.insert
local tbl_deep_extend = vim.tbl_deep_extend
local bo = vim.bo

--- @diagnostic disable-next-line: unused-local
local get_icon = function(filename, extension, options) return "" end
local deviconsOK, devicons = pcall(require, "nvim-web-devicons")
if deviconsOK then get_icon = devicons.get_icon end

local H = {}
local M = {}

--- @alias Contour.Buffer.Item
--- | `"filename"`
--- | `"relpath"`
--- | `"fullpath"`
--- | `"filetype"`
--- | `"typeicon"`
--- | `"modified"`
--- | `"bufnr"`

--- Displays buffer info.
--- @class Contour.Buffer
--- @field [1] "buffer"
--- The items to use when rendering the buffer. They will be separated by
--- spaces.
--- @field items? Contour.Buffer.Item[]
--- The icon to use for the "%m" item.
--- @field modified_icon? string
--- The default name to give unnamed buffers.
--- @field default_name? string
--- The highlight when rendering non-selected buffers.
--- @field highlight_norm? string|false
--- The highlight when the component is rendering the selected buffer.
--- @field highlight_sel? string|false
H.defaults = {
  "buffer",
  items = {
    "typeicon",
    "filename",
    "modified",
  },
  modified_icon = "*",
  default_name = "UNKNOWN",

  highlight_norm = "ContourBufferNorm",
  highlight_sel = "ContourBufferSel",
}

util.default_highlight("ContourBufferNorm", "StatusLineNC")
util.default_highlight("ContourBufferSel", "StatusLine")

--- Renders a buffer according to the given options, the configured options,
--- and the defaults in that order of priority. Renders the buffer in
--- context.buf, and checks it against context.curbuf.
--- @param opts Contour.Buffer Component spec override.
--- @param context Contour.Context Rendering context.
--- @return Contour.Primitive[] line
function M.render(opts, context)
  opts = tbl_deep_extend("keep", opts or {}, H.defaults)
  local line = {}
  local hl = highlight(context.current and opts.highlight_sel or opts.highlight_norm)
  tbl_insert(line, hl)
  tbl_insert(line, " ")
  local name = bufname(context.buf)

  for _, item in ipairs(opts.items) do
    if item == "filename" or item == "relpath" or item == "fullpath" then
      if not name or name == "" then
        line[#line] = line[#line] .. opts.default_name .. " "
      else
        local modifier = ({
          filename = ":t",
          relpath = ":~:.",
          fullpath = ":p",
        })[item]
        line[#line] = line[#line] .. fnamemodify(name, modifier) .. " "
      end
    elseif item == "filetype" then
      line[#line] = line[#line] .. bo[context.buf].filetype .. " "
    elseif item == "typeicon" then
      local fname = fnamemodify(name, ":t")
      local ft = bo[context.buf].filetype
      local icon = get_icon(fname, ft, { default = true })
      line[#line] = line[#line] .. icon .. " "
    elseif item == "modified" then
      if bo[context.buf].modified then
        line[#line] = line[#line] .. opts.modified_icon .. " "
      end
    elseif item == "bufnr" then
      line[#line] = line[#line] .. context.buf .. " "
    end
  end

  return line
end

return M
