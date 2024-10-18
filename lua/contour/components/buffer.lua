-- simirian's NeoVim contour
-- buffer component

local fnamemodify = vim.fn.fnamemodify
local bufname = vim.fn.bufname
local highlight = require("contour.util").highlight

--- @diagnostic disable-next-line: unused-local
local get_icon = function(filename, extension, options) return "" end
local deviconsOK, devicons = pcall(require, "nvim-web-devicons")
if deviconsOK then get_icon = devicons.get_icon end

local H = {}
local M = {}

--- @alias Contour.Buffer.Item
--- | `"filename"`,
--- | `"relpath"`,
--- | `"fullpath"`,
--- | `"filetype"`,
--- | `"typeicon"`,
--- | `"modified"`,
--- | `"bufnr"`,

--- Displays buffer info.
--- @class Contour.Buffer
--- Specifies the type of component.
--- @field [1] "buffer"
--- The items to use when rendering the buffer. They will be separated by
--- spaces.
--- @field items? Contour.Buffer.Item[]
--- The icon to use for the "%m" item.
--- @field modified_icon? string
--- The default name to give unnamed buffers.
--- @field default_name? string
--- The highlight when rendering non-selected buffers.
--- @field highlight_norm? string
--- The highlight when the component is rendering the selected buffer.
--- @field highlight_sel? string
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

vim.api.nvim_set_hl(0, "ContourBufferNorm", { link = "StatusLineNC" })
vim.api.nvim_set_hl(0, "ContourBufferSel", { link = "StatusLine" })

--- @type Contour.Buffer
H.config = setmetatable({}, { __index = H.defaults })

--- Renders a buffer according to the given options, the configured options,
--- and the defaults in that order of priority. Renders the buffer in
--- context.buf, and checks it against context.curbuf.
--- @param opts Contour.Buffer Component spec override.
--- @param context Contour.Context Rendering context.
--- @return Contour.Primitive[] line
function M.render(opts, context)
  opts = setmetatable(opts, { __index = H.config })
  local line = {
    highlight(context.current and opts.highlight_sel or opts.highlight_norm),
    " ",
  }
  local name = bufname(context.buf)

  for _, item in ipairs(opts.items) do
    if item == "filename" or item == "relpath" or item == "fullpath" then
      if not name or name == "" then
        line[2] = line[2] .. opts.default_name .. " "
      else
        local modifier = ({
          filename = ":t",
          relpath = ":~:.",
          fullpath = ":p",
        })[item]
        line[2] = line[2] .. fnamemodify(name, modifier) .. " "
      end
    elseif item == "filetype" then
      line[2] = line[2] .. vim.bo[context.buf].filetype .. " "
    elseif item == "typeicon" then
      local fname = fnamemodify(name, ":t")
      local ft = vim.bo[context.buf].filetype
      local icon = get_icon(fname, ft, { default = true })
      line[2] = line[2] .. icon .. " "
    elseif item == "modified" then
      if vim.bo[context.buf].modified then
        line[2] = line[2] .. opts.modified_icon .. " "
      end
    elseif item == "bufnr" then
      line[2] = line[2] .. context.buf .. " "
    end
  end

  return line
end

--- Sets up new default options for the buffer component.
--- @param opts Contour.Buffer
function M.setup(opts)
  H.config = setmetatable(opts or {}, { __index = H.defaults })
end

return M
