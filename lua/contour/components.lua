-- simirian's NeoVim contour
-- components module

local util = require("contour.util")

--- Get other componnet modules through table indexing, and print messages if
--- they do not exist. This module is meant to create a simple, unified API.
--- @type { [string]: Contour.Component }
return setmetatable({}, {
  __index = function(tbl, key)
    local exists, module = pcall(require, "contour.components." .. key)
    if exists then
      tbl[key] = module
      return tbl[key]
    end
    util.error("components", "Could not find component: " .. key)
    return nil
  end
})
