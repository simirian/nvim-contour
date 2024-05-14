# Nvim Contour

NeoVim statusline, tabline, and winbar plugin<br>
by simirian

## Features

Contour aims to be a thin lua wrapper of the vim statusline API, with additional high-level components for easy setup.
Contour lets you declare a statusline, tabline, or winbar as a list-like lua table, and will automatically generate and set everything needed.
Note that when this document refers to **lines** it is referring to the statusline, winbar, and tabline.
Special terms will be in **bold**.

- [x] setup functions for all **lines**
- [x] refresh functions for all **lines**
- [x] automagically make lua functions work in any **line**
- [x] group **items** with nested tables
- [x] **components** (classes? constructors? idk what to call these)
    - the custom **component** API is questionable, you have to `setmetatable()` your own tables, but it's not awful?
- [ ] full support for `'statusline'` escapes
- [ ] many built-in **components**
    - [x] tabs
    - [x] buffers
    - [ ] mode
    - [ ] git
    - [ ] diagnostics

## Installation

Lazy:

```lua
{
  "simirian/nvim-contour",
  -- don't use the opts key, it's meaningless with three different setups
  config = function()
    local contour = require("contour")
    contour.tabline.setup{
      -- your config here
    }
    -- statusline, etc.
  end,
}
```

## Configuration

Contour gives you three items to set up (all are optional): `contour.statusline`, `contour.winbar`, `contour.tabline`.
These each have a `setup` function and a `refresh` function.

- `setup` will set the **line** variable, `laststatus`, and `showtabline`.
- `refresh` will redraw that **line** by using either `:redrawtabline` or `:redrawstatus!`

### Setup

To use the setup functions, they need a **line** definition table.
This table is a list of **items** and an optional default highlight group.
The statusline also takes `mode` as a key and sets `laststatus`  to the key's value (`:help 'laststatus'`).
The tabline accepts `mode` as a key and sets `showtabline` to its value (`:help 'showtabline'`).

### Items

An **item** that can be added to a **line** is one of:

- a string to place in a **line**, which CAN contain statusline escapes
- a function to be called when the **line** is redrawn
- a **component** (table) with a `_render()` function, which will be called when the **line** is redrawn
- a **group** (table) which acts as a sublist of items

## Groups

**Groups** are a list of **items**, with a few extra keys:

| key | type | meaning |
| --- | --- | --- |
| `left` | boolean | Should this **group's** items be left-aligned WITHIN this group? |
| `min_width` | number | The minimum width of this **group**. |
| `max_width` | number | The maximum width of this **group**. |
| `highlight` | string | The default highlight group of this **group**. |

Note that the **line** you give to the setup functions is a **group** without width or alignment, as those would be meaningless.
If `highlight` is set after each item in the list the highlight will be set to the default, so components that set highlights should be put within subgroups.

## Components

This plugin provides a few preconfigured **components** in the module `contour.components`
**Components** MUST define a `_render()` function to be called when the **line** is redrawn.
To easily create your own **components**, it is recommended that you create a component table with a `render(self)` function, then set its metable to `components.component_metatable`.
Then you will be able to use that component like the plugin's built-in components.

Custom component example:

```lua
local components = require("contour.components")

-- create a RootDir component, that will display the cwd name
local RootDir = setmetatable({
  highlight = "Green",
  -- this function gets called every time the line is redrawn
  render = function(self)
    return vim.fn.fnamemodify(vim.fn.getcwd(), "t")
  end,
  -- we setmetatable to make sure that the _render() function is created on call
}, components.component_metatable)

require("contour").tabline.setup{
  -- always show tabline
  mode = 2,
  -- use call syntax to create a new component, think classes
  RootDir(),
  -- add some built-in components to flesh out the line
  components.spacer,
  components.Tabs(),
}
```

> NOTE: This is a contrived example, and optimally you would just put `"%{fnamemodify(getcwd(), ':t')}"` in your **line** instead.
> See `:help 'statusline'` to see how this works.

### String Items

There is a long table of string **items** that translate nearly one-to-one to statusline escapes.
Any members of `contour.components` not named hereafter come from this list. (eg. `spacer`, `fullpath`, etc.)
See `:help 'statusline'` to see where these come from, and use any that are not provided.

### Highlight

This is a function that pretends to be a **component**, call it with a highlight group name to get a string that will set the highlight group.
Call with nothing to reset the highlight group, this will vary between `StatusLine`, `WinBar`, and `TabLine` depending on which **line** it is used in.
Call with a number from 1-9 to set the highlight to `User{number}`.

> NOTE: Mostly used internally.
> It is recommended that you use groups and their highlights instead of this fake **component**.

### Tabs

This is a simple **component** that lists tabs by number, with mouse interaction and a close button.

| key | type | default | meaning |
| --- | --- | --- | --- |
| `highlight` | string | `"TabLine"` | The highlight group for inactive tabs. |
| `highlgiht_sel` | string | `"TabLineSel"` | The highlight group for the selected tab. |
| `close_icon` | string | `"x"` | The clickable close icon. |

### Buffers

This is a simple **component** that lists buffers by name:number, and marks them if they are modified.

| key | type | default | meaning |
| --- | --- | --- | --- |
| `highlight` | string | `"TabLine"` | The highlight group for inactive tabs. |
| `highlgiht_sel` | string | `"TabLine"` | The highlight group for the selected tab. |
| `modified icon` | string | `"+"` | The icon shown when a file is modified. |
| `show_bufnr` | boolean | `true` | If the buffer number should be shown after the buffer name. |
| `buffers` | table | `{ buflisted = true, bufloaded = true }` | Criteria for buffers to be listed. See `:help getbufinfo()`. |
| `default_name` | string | `UNNAMED` | The default file name for buffers whose names evaluate to empty with `:t`. See `:help filename-modifiers`. |

