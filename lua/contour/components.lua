-- simirian's NeoVim contour
-- components module

local iok, devicons = pcall(require, "nvim-web-devicons")
local vfn = vim.fn

--- Simple string components.
local M = {}

-- The metatable that makes components work automagically. Calling a table like
-- a constructor from other languages will make a component that automagically
-- works with the setup functions!
M.component_metatable = {
  __call = function(tbl, args)
    args = args or {}
    setmetatable(args, { __index = tbl })
    -- use this so we can access args:render() with v:lua
    -- this function will be registered with the functions module
    function args._render()
      return args:render()
    end

    return args
  end
}

--- Converts a highlight group name or number into a statusline highlight group.
--- @param group? string|number Highlight group or user group number.
--- @return string statusline
function M.Highlight(group)
  -- reset highlight to TabLine
  if not group then return "%0*" end
  -- set highlight to User{group}
  if type(group) == "number" then return "%" .. group .. "*" end
  -- with nothing we skip making a highlight
  if group == "" then return "" end
  -- set highlight to any other group
  return "%#" .. group .. "#"
end

-- This is the root component for rendering buffers. Many built-in components,
-- including `Buffers` and `TabBufs` will outsource to this component to draw
-- their buffers. Setting values in THIS EXACT table
-- `require("contour.components").Buf.****`
-- will cause buffer rendering to be modified globally. Of course this can
-- always be overridden anywhere you do not want that behavior.
M.Buf = setmetatable({
  -- highlight groups
  highlight = "",
  highlight_sel = "",
  -- file name variant
  --- @type "filename"|"fullpath"|"relpath"
  filename = "filename",
  -- name for buffers whose :t names are empty
  default_name = "UNKNOWN",
  -- modified indicator icon
  modified_icon = "+",
  -- should the filetype icon be shown
  show_icon = iok,
  -- should the bufnr be shown
  show_bufnr = false,

  render = function(self, bufnr)
    -- get bufnr and bufname
    bufnr = bufnr or vfn.bufnr("%")
    local bufname = vfn.bufname(bufnr)

    -- set icon based on bufname
    local icon = ""
    if self.show_icon then
      local i = devicons.get_icon(bufname)
      if i then icon = " " .. i end
    end

    -- refile bufname based on our values
    if self.filename == "filename" then
      bufname = vfn.fnamemodify(bufname, ":t")
    elseif self.filename == "fullpath" then
      bufname = vfn.fnamemodify(bufname, ":p")
    elseif self.filename == "relpath" then
      bufname = vfn.fnamemodify(bufname, ":p:.")
    end
    if not bufname or bufname == "" then
      bufname = self.default_name
    end

    -- figure out highlight
    local hl = ""
    if bufnr == vfn.bufnr("%") then
      hl = M.Highlight(self.highlight_sel)
    else
      hl = M.Highlight(self.highlight)
    end

    -- modified icon
    local mod = ""
    if vim.bo[bufnr].modified then
      mod = self.modified_icon .. " "
    end

    local nrstr = ""
    if self.show_bufnr then
      nrstr = ":" .. bufnr
    end

    -- put it all together
    return hl .. icon .. " " .. bufname .. nrstr .. " " .. mod
  end
}, M.component_metatable)

-- This component lists tabs by tabnr, with a close button for each.
M.Tabs = setmetatable({
  -- the default highlight group
  highlight = "TabLine",
  -- the selected highlight group
  highlight_sel = "TabLineSel",
  -- the icon to use for the close button
  close_icon = "x",
  -- the icon to indicate the tab has modified files
  modified_icon = "+",

  -- used to render the component, called on update
  render = function(self)
    local str = ""
    for tab = 1, vfn.tabpagenr("$") do
      str = str .. self:tabrender(tab)
    end
    return str
  end,

  -- tabrender function, how each tab is rendered
  tabrender = function(self, tabnr)
    local hl = vfn.tabpagenr() == tabnr and M.Highlight(self.highlight_sel)
        or M.Highlight(self.highlight)
    local bufs = vfn.tabpagebuflist()
    local icon = self.close_icon
    for _, bufnr in ipairs(bufs) do
      if vim.bo[bufnr].modified
          and vim.bo[bufnr].buflisted
          and vfn.bufloaded(bufnr) == 1
      then
        icon = self.modified_icon
      end
    end

    -- tab number section
    return hl .. "%" .. tabnr .. "T " .. tabnr ..
        -- close icon section (with click close action)
        " %" .. tabnr .. "X" .. icon .. " %X"
  end,

}, M.component_metatable)

-- This component lists buffers, their icons and if they are modified. Uses
-- `Buf` as a root, so it inherits all the global settings from that, and
-- overrides can be given on any `Buffers` instance.
M.Buffers = setmetatable({
  -- highlight for the current buffer
  highlight_sel = "TabLineSel",
  -- what buffers to include
  buffers = {
    buflisted = true,
    bufloaded = true,
  },
  -- Buf() overrides
  highlight = "TabLine",

  -- used to render the component, called on update
  render = function(self)
    local str = ""
    for _, buf in ipairs(vfn.getbufinfo(self.buffers)) do
      str = str .. self:bufrender(buf.bufnr)
    end
    return str
  end,

  bufrender = M.Buf.render

  -- this inherits from M.Buf so we can use its settings and bufrender
}, vim.tbl_deep_extend("error", M.component_metatable, { __index = M.Buf }))

-- Lists tabs by number, and the buffers in them. Inherits `Buf` settings, and
-- allows overrides.
M.TabBufs = setmetatable({
  -- default highlight group
  highlight = "Tabline",
  -- selected tab highlight group
  highlight_sel = "TabLineSel",
  -- close tab icon
  close_icon = "x",
  -- which buffers to include in the list
  buffers = {
    buflisted = true,
    bufloaded = true,
  },

  render = function(self)
    local str = M.Highlight(self.highlight)
    for tab = 1, vfn.tabpagenr("$") do
      if vfn.tabpagenr() == tab then
        str = str .. M.Highlight(self.highlight_sel)
      end
      str = str .. self:tabrender(tab)
      if vfn.tabpagenr() == tab then
        str = str .. M.Highlight(self.highlight)
      end
    end
    return str
  end,

  tabrender = function(self, tabnr)
    local str = "%" .. tabnr .. "T (" .. tabnr .. ")"

    for _, bufnr in ipairs(vfn.tabpagebuflist(tabnr)) do
      if
          ((not self.buffers.buflisted) or vfn.buflisted(bufnr) == 1)
          and ((not self.buffers.bufloaded) or vfn.bufloaded(bufnr) == 1)
          and ((not self.buffers.bufmodified) or vim.bo[bufnr].modified)
      then
        str = str .. self:bufrender(bufnr)
      end
    end

    return str .. "%" .. tabnr .. "X " .. self.close_icon .. " %X"
  end,

  bufrender = function(self, bufnr)
    local tmptbl = vim.deepcopy(self)
    tmptbl.highlight = ""
    tmptbl.highlight_sel = ""
    return M.Buf.render(tmptbl, bufnr)
    --return M.Buf.render(self, bufnr)
  end

  -- this inherits from buf so we can use its settings
}, vim.tbl_deep_extend("error", M.component_metatable, { __index = M.Buf }))

return M
