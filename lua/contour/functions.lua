-- simirian's NeoVim contour
-- functions module

local M = { _rfcache = {} }

function M.fncomponent(fn)
  local str = "%{%v:lua.require'contour.functions'._rfcache.f"

  -- loop through all the existing chached functions
  local i = 1
  while M._rfcache["f" .. i] and i < 10 do
    -- if we find a match, then return it
    if M._rfcache[i] == fn then
      return str .. i .. "()%}"
    end
    i = i + 1
  end

  -- otherwise we are dumped off the loop with a new index
  M._rfcache["f" .. i] = fn
  return str .. i .. "()%}"
end

return M
