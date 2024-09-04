# Nvim Contour

by simirian

NeoVim plugin for easy but statusline, tabline, and winbar configuration, with
an emphasis on user control.<br>

## Features

Contour aims to be a thin lua wrapper of the vim statusline API, with additional
high-level components for easy setup. Contour lets you declare a statusline,
tabline, or winbar as a list-like lua table with additional properties. It will
automagically generate and set everything needed. Note that when this document
refers to lines it is referring to the statusline, winbar, and tabline.

This plugin is best used with knowledge of the statusline api, see `:help
statusline.` Other parts of nvim's help documentation will be referenced
throughout this README.

- [x] automagically make lua functions work in any line
- [ ] click callback functions
- [x] group items with nested tables
- [x] components (classes? constructors? idk what to call these)
- [ ] many built-in components
    - [x] tabs (tab numbers)
    - [x] buffers (buffers list)
    - [x] tab buffers (tab numbers with a list of their buffers)
    - [x] buffer (includes name, filetype icon, modified icon)
    - [ ] vim mode display
    - [ ] diagnostics
    - [ ] git branch / status
    - [ ] git diff (merge with above?)
    - [ ] last search

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

- `setup` will set the line option, `laststatus`, and `showtabline`.
- `refresh` will redraw that line by using either `:redrawtabline` or
  `:redrawstatus!`

The setup functions all require a line spec, which is a list-like lua table of
items with an optional key for setting a highlight group. The statusline setup
function also expects a mode to set `'laststatus'` to. The tabline setup
function expects a mode to set `'showtabline'` to.

THIS SECTION IS A WORK IN PROGRESS AND ABOUT TO CHANGE

## Items

Items can be added to lines through setup. Items can be one of the following:

- a string to place in a line, which can (and probably should) contain
  statusline escapes
- a function to be called every time line is redrawn
    - this function will not receive arguments, and should return something that
      can be concatenated with strings
    - this function's output is treated as statusline text, so `%` escapes
      will work
- a group (table) which acts as a list of items that share some formatting
  information between them

Components can also be added to lines, but it is worth noting that components
are very fancy wrappers for functions. They use some scope magic so that when
you call `new()` (or the component itself) they will produce a function with no
arguments that is capable of rendering the component with the given options.

### Groups

Groups are a list of items, with a few extra keys:

| key | type | default | meaning |
| --- | --- | --- | --- |
| `left` | boolean | right-aligned | Should this group's items be left-aligned WITHIN this group? |
| `min_width` | number | no minimum | The minimum width of this group. |
| `max_width` | number | no maximum | The maximum width of this group. |
| `highlight` | string | no highlight override | The default highlight group of this group. |

A group will display the items in the list in orders, joined together with no
spacing. The highlight will be set to the group's `highlight` at the start and
after each item. For some reason the `%=` spacer does not work inside groups,
it's just how nvim works. If you want a spacer, put it *between* your groups and
set the spacer's highlight *after* the first group.

### Highlight

This is a helper function that takes an optional string and gives you the
statusline string needed to set that highlight group. Providing an empty string
(`""`) will result in the highlight group resetting to `TabLine`, `StatusLine`,
etc. depending on where the line is being rendered. Providing `nil` will not
change anything. Providing a string (`"HighlightGroup"`) with an actual
highlight group name will set the line to use that highlight group.

Manual highlighting is possible, but it is much easier to use groups with the
`highlight` key set. Components are not responsible for resetting their
highlight, and will highlight everything after them unless this is done. Groups
will automatically set the highlight to the group's highlight after each item.

### Components

This plugin provides a few preconfigured components in the module
`contour.components`, and methods to make your own. Each component has several
important functions.

`new(opts)` will return a `fun(): string` which can be embedded into the
sttausline. This function will respect the config passed into new, then the
module's config that you've set up, then the default config.

`setup(opts)` lets you override the rendering of a component globally. (Options
passed to `new()` will override this.) This will apply to all components that
inherit options as well. For example, running setup on the `Buffer` component
will change buffer rendering in all `Buffer`, `BufList`, and `TabBufs`
components as long as they are not overridden in `new()`.

You can view a component's defaults in the `defaults` key, but you *should not*
set this key to another value. That will break the inheritance chain and
probably result in errors.

By defualt all icons use ascii, to be compatible with non-gui environments and
users without patched fonts. It is trivial to override this globally for each
component by setting the class fields.

```lua
require("contour.buffer").setup{ filetype = "icon" }
require("contour.tablist").setup{ close_icon = "YOUR ICON" }
-- repeat for other components you use

-- you can also just change the settings with new()
local tbcomponent = require("contour.tabbufs").new{ close_icon = "YOUR ICON" }
-- other TabBuf componets will not use this icon though
```

Components are internally tables, but they can be called like class constructors
in other languages. If you implement your own (examples later), this
functionality will be automatic!

Components internally just use scopes and parameter-free functions to manage
options inheritance and create a valid parameter-free function for the functions
module to use.

#### Buffer

This component provides information about a buffer. Most of the difficult
rendering occurs in `render_buffer()`, which takes a buffer number and options
as an argument. This means that other components can just use this function
themselves to render any buffers they need. The `render()` function just calls
`render_buffer()` with the current buffer, and works by default in the
statusline.

```lua
-- default values
buffer.setup {
  highlight = nil,
  highlight_sel = nil,
  filename = "filename",
  filetype = "text",
  default_name = "UNKNOWN",
  modified_icon = "*",
  show_bufnr = false,
} 
```

#### TabList

This is a simple component that lists tabs by number, with mouse interaction and
a close button. If any tab is modified, it will be marked with `modified_icon`.

```lua
-- default values
tablist.setup {
  highlight = "TabLine",
  highlight_sel = "TabLineSel",
  close_icon = "x",
  modified_icon = "*",
}
```

#### BufList

This component lists all open tabs. Which tabs get shown can be configured with
a filter function. This component accepts all `Buffer` option keys as well as
its own, and uses the buffer's `render_buffer()` function, with its options. By
default, any options not specified on the `BufList` will be inherited from the
`Buffer` component, this *does* respect user configuration via `setup()` as you
would expect.

```lua
local buffer = require("contour.buffer")
local buflist = require("contour.buflist")
-- this will set icon filetypes for the buflist as well
buffer.setup{ filetype = "icon" }
buflist.defaults.filetype == "icon" -- true
```

```lua
-- default values
buflist.setup {
  highlight = "TabLine",
  highlight_sel = "TabLineSel",
}
-- this makes it so we only see buffers we want to, instead of things like
--   telescope prompts or other temporary buffers
function buflist.defaults.filter(bufnr)
  local bi = vfn.getbufinfo(bufnr)[1]
  return bi.listed == 1 and bi.loaded == 1
end
```

#### TabBufs

This component lists tabs by their numbers, and within each tab label it will
also list the buffers visible in that tab. This component renders buffer lists
like the `BufList` component, and inherits all of its configuration options.

```lua
-- default values
tabbufs.setup {
  highlight_buf_sel = "TabLineSel",
  close_icon = "x",
}
```

#### Custom Components

To make your own components you can use the `create(defaults)` function. This
returns a table which is the component module. To make your component work, you
simply need to define a `render(opts)` function on the component.

```lua
local defaults = {
  text = "Hello world!",
  -- any keys here, they get passed to render()
}

-- you can set the metatable of your defaults to another component's public
--   defaults (component.defaults) to inherit from it
-- setmetatable(defaults { __index = PARENT })

-- create you component class
local my_component = require("contour.components").create(defaults)

-- implement rendering
function my_component.render(opts)
  -- opts will at the bare minimum be the table you defined above as defaults
  -- if the user creates your component with new() and passes new options, you
  --   will get those options here, and any they skip will be from defaults
  return opts.text or "no text"
end
-- now you can use setup() and new(), and they work as expected

require("contour").statusline.setup{
  my_component.new(),
  my_component(),
  -- other items here
}
```

