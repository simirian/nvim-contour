-- simirian's NeoVim contour
-- components module

local vfn = vim.fn

--- Simple string components.
local M = {
  relpath   = "%f",
  fullpath  = "%F",
  filename  = "%t",
  modified  = "%M",
  readonly  = "%R",
  help      = "%H",
  preview   = "%W",
  filetype  = "%Y",
  quickfix  = "%q",
  keymap    = "%k",
  bufnr     = "%n",
  charcode  = "%B",
  bytenr    = "%O",
  linenr    = "%l",
  linecount = "%L",
  colnr     = "%c%V",
  percent   = "%P",
  showcmd   = "%S",
  arglist   = "%a",
  spacer    = "%=",
}

M.component_metatable = {
  __call = function(tbl, args)
    setmetatable(args, { __index = tbl })
    -- use this so we can access args:render() with v:lua
    -- this function will be registered with the functions module
    function args._render()
      return args:render()
    end

    return args
  end
}

M.Highlight = function(group)
  -- reset highlight to TabLine
  if not group then return "%0*" end
  -- set highlight to User{group}
  if type(group) == "number" then return "%" .. group .. "*" end
  -- set highlight to any other group
  return "%#" .. group .. "#"
end

M.Tabs = setmetatable({
  -- default highlight group
  highlight = "TabLine",
  -- highlight group of the current tab
  highlight_sel = "TabLineSel",
  -- shat should the close icon be
  close_icon = "x",

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
    -- set highlight based on if we are active or not
    return (vim.fn.tabpagenr() == tabnr and M.Highlight(self.highlight_sel)
          or M.Highlight(self.highlight))
        -- tabnr section (with click navigate action)
        .. "%" .. tabnr .. "T " .. tabnr ..
        -- close icon section (with click close action)
        " %" .. tabnr .. "X" .. self.close_icon .. " %X"
  end,

}, M.component_metatable)

M.Buffers = setmetatable({
  -- default highlight
  highlight = "TabLine",
  -- highlight for the current buffer
  highlight_sel = "TabLineSel",
  -- icon to indicate if the file is modified
  modified_icon = "+",
  -- should we show the bufner as well
  show_bufnr = true,
  -- the name to be used if the computed name is empty
  default_name = "UNNAMED",
  -- what buffers to include
  buffers = {
    buflisted = true,
    bufloaded = true,
  },

  -- used to render the component, called on update
  render = function(self)
    local str = ""
    for _, buf in ipairs(vim.fn.getbufinfo(self.buffers)) do
      str = str .. self:bufrender(buf.bufnr)
    end
    return str
  end,

  -- bufrender function, how each buffer is rendered
  bufrender = function(self, bufnr)
    local fname = vfn.fnamemodify(vfn.bufname(bufnr), ":t")
    if fname == "" then fname = self.default_name end
    local hl = vfn.bufnr() == bufnr and M.Highlight(self.highlight_sel)
        or M.Highlight(self.highlight)
    local bufnrstr = self.show_bufnr and ":" .. bufnr or ""
    local modified = vim.bo[bufnr].modified and " " .. self.modified_icon or ""

    -- highlight
    return hl .. " " .. fname .. bufnrstr .. modified .. " "
  end,

}, M.component_metatable)

return M
