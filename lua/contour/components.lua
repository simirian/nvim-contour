-- simirian's NeoVim contour
-- components module

local util = require("contour.util")

local H = {}
local M = {}

--- Lists all existing component modules.
--- @return string[] components
function M.list()
  return vim.tbl_map(
    function(e) return vim.fn.fnamemodify(e, ":t:r") end,
    vim.api.nvim_get_runtime_file("lua/contour/components/*.lua", true))
end

H.compcache = {}

--- @class Contour.ComponentModule
--- Renders a component with the given options.
--- @field render fun(Contour.Component, Contour.Context): Contour.Primitive[]

--- Gets a component module by name, handling all requires automagically.
--- @param name string The name of the desired component.
--- @return Contour.ComponentModule? module
function M.get(name)
    local ok, component = pcall(require, "contour.components." .. name)
    if not ok then
      util.error_once("components", "Attempted to use a nonexistant component: " .. name)
      return
    end
    return component
end

return setmetatable(M, H.mt)
