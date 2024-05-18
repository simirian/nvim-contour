# Nvim Contour

NeoVim plugin for easy statusline, tabline, and winbar plugin<br>
by simirian

## Features

Contour aims to be a thin lua wrapper of the vim statusline API, with
additional high-level components for easy setup. Contour lets you declare a
statusline, tabline, or winbar as a list-like lua table, and will automatically
generate and set everything needed. Note that when this document refers to
**lines** it is referring to the statusline, winbar, and tabline. Special terms
will be in **bold**.

- [x] setup functions for all **lines**
- [x] refresh functions for all **lines**
- [x] automagically make lua functions work in any **line**
- [x] group **items** with nested tables
- [x] **components** (classes? constructors? idk what to call these)
    - the custom **component** API is questionable, you have to
      `setmetatable()` your own tables, but it's not awful?
- [ ] mouse callback functions
- [x] ~~full support for `'statusline'` escapes~~
    - this is out of scope: we do strings already so "read the docs" tm
- [ ] high-level alternatives to statusline escapes
    - [x] buffer name
    - [x] buffer modified (attached to above)
    - [ ] readonly buffer
    - [x] filetype (icon on `Buf`)
    - [ ] position
    - [x] `%(%)` groups
- [ ] many built-in **components**
    - [x] tabs (tab numbers)
    - [x] buffers (buffers list)
    - [x] tab buffers (tab numbers with a list of their buffers)
    - [ ] buffer (includes name, filetype icon, modified icon)
    - [ ] vim mode
    - [ ] git branch / status
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

Contour gives you three items to set up (all are optional):
`contour.statusline`, `contour.winbar`, `contour.tabline`. These each have a
`setup` function and a `refresh` function.

- `setup` will set the **line** variable, `laststatus`, and `showtabline`.
- `refresh` will redraw that **line** by using either `:redrawtabline` or
  `:redrawstatus!`

### Setup

To use the setup functions, they need a **line** definition table. This table
is a list of **items** and an optional default highlight group. The statusline
also takes `mode` as a key and sets `laststatus`  to the key's value (`:help
'laststatus'`). The tabline accepts `mode` as a key and sets `showtabline` to
its value (`:help 'showtabline'`).

### Items

An **item** that can be added to a **line** is one of:

- a string to place in a **line**, which CAN contain statusline escapes
- a function to be called when the **line** is redrawn
- a **component** (table) with a `_render()` function, which will be called
  when the **line** is redrawn
- a **group** (table) which acts as a sublist of items

## Groups

**Groups** are a list of **items**, with a few extra keys:

| key | type | meaning |
| --- | --- | --- |
| `left` | boolean | Should this **group's** items be left-aligned WITHIN this group? |
| `min_width` | number | The minimum width of this **group**. |
| `max_width` | number | The maximum width of this **group**. |
| `highlight` | string | The default highlight group of this **group**. |

Note that the **line** you give to the setup functions is a **group** without
width or alignment, as those would be meaningless. If `highlight` is set after
each item in the list the highlight will be set to the default, so components
that set highlights should be put within subgroups.

## Components

This plugin provides a few preconfigured **components** in the module
`contour.components` **Components** MUST define a `_render()` function to be
called when the **line** is redrawn. To easily create your own **components**,
it is recommended that you create a component table with a `render(self)`
function, then set its metable to `components.component_metatable`. Then you
will be able to use that component like the plugin's built-in components.

Usage example:

```lua
local components = require("contour.components")
-- let's pretend you have a globals module with nerdfont icons in it
local globals = require("globals")

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
  -- provide a table to override the default values
  components.Tabs{
    -- override the default ascii with nerdfont icons
    modified_icon = globals.icons.modified,
    close_icon = globals.icons.close,
  },
}
```

> NOTE: This is a contrived example, and optimally you would just put
> `"%{fnamemodify(getcwd(), ':t')}"` in your **line** instead of this RootDir
> component. See `:help 'statusline'` to see how this works.

By defualt all icons are ascii, to be compatible with non-gui environments and
users without patched fonts. It is trivial to override this for each component
by setting the its global values.

Global overrides:

```lua
local components = require("contour.components")
-- let's pretend you have a globals module with nerdfont icons in it
local globals = require("globals")

-- set the modified icon to a random string
components.Buf.modified_icon = globals.icons.modified
-- change the default name for files
components.Buf.default_name = "?"

-- now using `components`.Buf() will use these new settings
```

This can be done with any setting on any component. Note that
[Highlight](#Highlight) pretends to be a component but is actually just a
function.

### Highlight

This is a function that pretends to be a **component**, call it with a
highlight group name to get a string that will set the highlight group. Call
with nothing to reset the highlight group, this will vary between `StatusLine`,
`WinBar`, and `TabLine` depending on which **line** it is used in. Call with a
number from 1-9 to set the highlight to `User{number}`.

> NOTE: Mostly used internally. It is recommended that you use groups and their
> highlights instead of this fake **component**.

### Buf

This component provides information about the a buffer. By default, gives
information about the current buffer. It is used by [Buffers](#Buffers) and
[TabBufs](#TabBufs) to render their buffers. Setting module settings for this
component will also change the rendering of buffers in `Buffers` and `TabBufs`.
Note that you can just override the `:render(bufnr)` function to completely
change buffer rendering. The `bufnr` argument is used for buffer lists.

| key | type | default | meaning |
| --- | --- | --- | --- |
| `highlight` | string | `""` | The highlight group for inactive buffers. Empty by default because this component may be used in the tabline OR the statusline. |
| `highlight_sel` | string | `""` | The highlight group for active buffers. Empty as above. |
| `filename` | `"filename"`\|`"fullpath"`\|`"relpath"` | `"filename"` | How the name of this buffer should be displayed. |
| `default_name` | string | `"UNKNOWN"` | The default name for buffers whose names evaluate to empty after the above modifications. |
| `modified_icon` | string | `"+"` | The indicator for modified files. |
| `show_icon` | boolean | true | If the filetype icon should be shown. This is on by default, and will automatically turn off if `nvim-web-devicons` cannot be loaded. It is highly recommended that you do not turn this on manually. |
| `show_bufnr` | boolean | false | If the bufner should be shown after the file name like so: `file.txt:23`. |

### Tabs

This is a simple **component** that lists tabs by number, with mouse
interaction and a close button.

| key | type | default | meaning |
| --- | --- | --- | --- |
| `highlight` | string | `"TabLine"` | The highlight group for inactive tabs. |
| `highlgiht_sel` | string | `"TabLineSel"` | The highlight group for the selected tab. |
| `close_icon` | string | `"x"` | The clickable close icon. |

### Buffers

This is a simple **component** that lists buffers by name:number, and marks
them if they are modified.

| key | type | default | meaning |
| --- | --- | --- | --- |
| `highlight` | string | `"TabLine"` | The highlight group for inactive tabs. |
| `highlgiht_sel` | string | `"TabLine"` | The highlight group for the selected tab. |
| `buffers` | table | `{ buflisted = true, bufloaded = true }` | Criteria for buffers to be listed. See `:help getbufinfo()`. Modification not recommended. |

Buffers uses the [Buf](#Buf) component internally, so also accepts its keys.

### TabBufs

This component lists tabs by their numbers, and within each tab label it will
also list the buffers visible in that tab. This component inherits [Buf](#Buf)
settigs for listing buffers.

| key | type | default | meaning |
| --- | --- | --- | --- |
| `highlight` | string | `"TabLine"` | The highlight group for inactive tabs. |
| `highlgiht_sel` | string | `"TabLine"` | The highlight group for the selected tab. |
| `close_icon` | string | `"x"` | The clickable close icon. |
| `buffers` | table | `{ buflisted = true, bufloaded = true }` | Criteria for buffers to be listed. See `:help getbufinfo()`. Modification not recommended. |

TabBufs uses the [Buf](#Buf) component internally, so also accepts its key.

