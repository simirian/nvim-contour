# Nvim Contour

NeoVim plugin for easy statusline, tabline, and winbar plugin<br>
by simirian

## Features

Contour aims to be a thin lua wrapper of the vim statusline API, with additional
high-level components for easy setup. Contour lets you declare a statusline,
tabline, or winbar as a list-like lua table with additional properties. It will
automagically generate and set everything needed. Note that when this document
refers to **lines** it is referring to the statusline, winbar, and tabline.
Special terms will be in **bold**.

This plugin is best used with knowledge of the statusline api, see `:help
statusline. Other parts of nvim's help documentation will be referenced
throughout this README.

- [x] automagically make lua functions work in any **line**
- [ ] click callback functions
- [x] group **items** with nested tables
- [ ] mouse callback functions
- [x] ~~full support for statusline escapes~~
    - this is out of scope: we do strings already so "read the docs"
- [x] **components** (classes? constructors? idk what to call these)
- [x] ~~high-level alternatives to statusline escapes~~
    - again, this is out of scope: use a built-in component or just use
      statusline escapes
- [ ] many built-in **components**
    - [x] tabs (tab numbers)
    - [x] buffers (buffers list)
    - [x] tab buffers (tab numbers with a list of their buffers)
    - [x] buffer (includes name, filetype icon, modified icon)
    - [ ] vim mode display
    - [ ] diagnostics
    - [ ] git branch / status

## Installation

Lazy:

```lua
{
  "simirian/nvim-contour",
  -- don't use the opts key, it's meaningless with three different setups
  config = function()
    local contour = require("contour")
    contour.statusline.setup{
      -- your config here
    }
    -- other lines
  end,
}
```

## Configuration

Contour gives you three items to set up (all are optional):
`contour.statusline`, `contour.winbar`, `contour.tabline`. These each have a
`setup` function and a `refresh` function.

- `setup` will set the **line** option, `laststatus`, and `showtabline`.
- `refresh` will redraw that **line** by using either `:redrawtabline` or
  `:redrawstatus!`

### Setup

The setup functions all require a **line** spec, which is a list-like lua table
of **item**s with an optional key for setting a highlight group. The statusline
setup function also expects a mode to set `'laststatus'` to. The tabline setup
function expects a mode to set `'showtabline'` to.

### Items

An **item** that can be added to a **line** is one of:

- a string to place in a **line**, which CAN contain statusline escapes
- a function to be called when the **line** is redrawn
    - this function's output is treated as statusline text, so `%` escapes
      *will* work
- a **component** (table) with a `_render()` function, which will be called when
  the **line** is redrawn
    - the `_render()` function is processed as above, so the same applies to `%`
- a **group** (table) which acts as a sublist of items

## Groups

**Groups** are a list of **items**, with a few extra keys:

| key | type | default | meaning |
| --- | --- | --- | --- |
| `left` | boolean | right-aligned | Should this **group's** items be left-aligned WITHIN this group? |
| `min_width` | number | no minimum | The minimum width of this **group**. |
| `max_width` | number | no maximum | The maximum width of this **group**. |
| `highlight` | string | no highlight override | The default highlight group of this **group**. |

Note that the **line** you give to the setup functions is a **group** without
width or alignment, as those would be meaningless. If `highlight` is set, then
after each item in the list the highlight will be reset, so components that set
highlights should be put within subgroups.

Not supplying any of these keys will leave them as their default values.

## Components

This plugin provides a few preconfigured **components** in the module
`contour.components`, and methods to make your own.

By defualt all icons use ascii, to be compatible with non-gui environments and
users without patched fonts. It is trivial to override this globally for each
component by setting the class fields.

```lua
local c = require("contour.components")
-- let's pretend you have a globals module with nerdfont icons in it
local globals = require("globals")

-- globally set the modified item icon to any string
c.buffer.modified_icon = globals.icons.modified
c.tablist.modified_icon = globals.icons.modified
```

### Highlight

 #TODO: move highlight

This is a function that pretends to be a **component**, call it with a
highlight group name to get a string that will set the highlight group. Call
with nothing to reset the highlight group, this will vary between `StatusLine`,
`WinBar`, and `TabLine` depending on which **line** it is used in. Call with a
number from 1-9 to set the highlight to `User{number}`.

```lua
local c = require("contour.components")
local statusline = {
    highlight = nil, -- ensure we don't highlight
    c.highlight("StatuLine"), -- highlight with statusline
    c.highlight(3), -- highlight with the "User3" group
    c.highlight(""), -- don't change highlight
    c.highlight(), -- reset highlight
}
```

> NOTE: Mostly used internally. It is recommended that you use groups and their
> highlights instead of this fake **component**.

### Buffer

This **component** provides information about a buffer. By default, it renders
the current buffer, but it can also be used to render any buffer if `:render()`
is called with a buffer number. This component is used by other components that
have to render buffers, so any changes to `Buffer` defaults will change how
those components render as well.

```lua
local c = require("contour.components")
local b = c.buffer

-- Changes to the `Buffer` class are global, and will even affect `BufList` and
-- other components that render buffers.
b.show_bufnr = true

local statusline = {
    -- instance properties only affect this buffer
    b {
        show_bufnr = false,
        filename = "relpath",
    }
}
```

### TabList

This is a simple **component** that lists tabs by number, with mouse
interaction and a close button.

```lua
local c = require("contour.components")
local tl = c.tablist

local tabline = {
    tl {
        modified_icon = "*", -- icon for when tab has modified buffers
    },
}
```

### BufList

This is a simple **component** that lists a configurable selection of active
buffers. Buffers are rendered according to [Buffer](#Buffer), but this can be
overridden.

```lua
local c = require("contour.components")
local b = c.buffer
local bl = c.buflist

b.show_bufnr = true -- show buffer numbers after names
local tabline = {
    bl(), -- shows a list of buffers, with numbers according to above setting
    bl {
        show_bufnr = false, -- override `Buffer` settings
        buffers = {}, -- show all buffers, not just listed, loaded buffers
    },
}
```

### TabBufs

This **component** lists tabs by their numbers, and within each tab label it
will also list the buffers visible in that tab. This **component** renders
buffer lists like the [BufList](#BufList) **component**, and inherits all of its
properties.

```lua
local c = require("contour.components")
local b = c.buffer
local tb = c.tabbufs

b.show_bufnr = true -- show buffer number whenever buffers are rendered
local tabline = {
    tb {
        buffers = { -- change `BufList` settings
            buflisted = true,
            bufloaded = true,
            bufmodified = true,
        },
        filetype = "text", -- change `Buffer` settings as well
        close_icon = "CLOSE", -- or just change tabbufs settings
    },
}
```

### Custom Components

You can easily make your own components. A component is really just a wrapper to
a `_render()` function which is used like any other function. To easily make
your own components, create a table with a `:render()` function, then use the
`apply_metatable()` function to make it a class-like component.

```lua
local c = require("contour.components")

-- define your table
local TimeComponent = {
    format = "%H:%M",
}

-- add the mandatory `:render()` function
function TimeComponent:render()
    return vim.fn.strftime(self.format)
end

-- then set the metatable
c.apply_metatable(TimeComponent)
-- optionally add a parent class to inherit from
--c.apply_metatable(TimeComponent, TimeClass)

-- then you can use it like any other component
local tabline = {
    TimeComponent(), -- uses default settings
    TimeComponent { format = "%Y-%m-%d" } -- or do change it up
}
```

The above example is the simplest and most versatile way to create custom
components. The component's `_render()` function cannot take `self` as an
argument, and this method automatically works around this in the background. If
you want to set `_render()` yourself, consider just using a function instead.
