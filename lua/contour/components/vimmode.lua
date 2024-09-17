-- simirian's NeoVim contour
-- VimMode component class

local vfn = vim.fn
local util = require("contour.util")

local H = {}

--- @enum (key) Contour.VimMode.ModeChar
H.modechars = { -- switch pattern
  n        = { long = "  Normal  ", letter = "N" },
  i        = { long = "  Insert  ", letter = "I" },
  R        = { long = " Replace  ", letter = "R" },
  t        = { long = " Terminal ", letter = "T" },
  c        = { long = " Command  ", letter = "C" },
  v        = { long = "  Visual  ", letter = "V" },
  V        = { long = "  V-Line  ", letter = "V" },
  ["\x16"] = { long = " V-Block  ", letter = "V" }, -- ctrl v
  s        = { long = "  Select  ", letter = "S" },
  S        = { long = "  S-Line  ", letter = "S" },
  ["\x13"] = { long = " S-Block  ", letter = "S" }, -- ctrl s
  r        = { long = "  Prompt  ", letter = "P" },
  ["!"]    = { long = "  Shell   ", letter = "$" },
}

--- Options for the VimMode component.
--- @class Contour.VimMode.Opts
--- @field highlight? string|table<Contour.VimMode.ModeChar|"base", string>
--- @field display? "long"|"letter" how to display the mode
H.defaults = {
  highlight = nil,
  display = "letter",
}

--- @class Contour.VimMode: Contour.Component
local M = util.component(H.defaults, "vimmode")

--- Renders the current vim mode.
--- @param opts Contour.VimMode.Opts The rendering options.
--- @return string statusline
function M.render(opts)
  local modechar = vfn.mode():sub(1, 1)
  local hl = type(opts.highlight) == "table"
      and util.highlight(opts.highlight[modechar] or opts.highlight.base)
      or util.highlight(opts.highlight --[[ @as string? ]])

  -- just lua things lmao, this indexing is a mess
  return ("%s %s "):format(hl, H.modechars[modechar][opts.display])
end

vim.api.nvim_create_autocmd("ModeChanged", {
  group = vim.api.nvim_create_augroup("NvimManager", { clear = false }),
  command = "redrawtabline|redrawstatus"
})

return M
