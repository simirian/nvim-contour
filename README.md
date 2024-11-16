# Nvim Contour

by simirian

NeoVim plugin for easy statusline, tabline, and winbar configuration.

## Features

- [ ] click callback functions
- [ ] per-filetype configuration
- [x] implementation of equivalent all 'statusline' options, or allow their
  direct usage (raw statusline component)
- [ ] components
    - [x] group (multiple components in one, with truncation)
    - [x] space (spacing and alignment component)
    - [x] raw (raw statusline strings)
    - [x] function (user lambda functions)
    - [x] buffer
    - [x] buflist
    - [x] tab
    - [ ] *tablist*
    - [x] diagnostics
    - [ ] *vim mode display*
    - [ ] git branch / status
    - [ ] git diff (merge with above?)
    - [ ] last search
    - [ ] custom creation api

## Installation

Just use lazy. `"simirian/nvim-contour"`

## Configuration

Configuration occurs in a single table passed to the `setup()` function. The
main configuration table lets you set up the statusline, tabline, and winbar in
their respectively named keys. The each of those values expects a table. The
keys of that table are either `"default"` to set up a global line, or a single
string file type or a string array of file types which the line should attach
to. The values in the line's tables are just the line specs, which really is
just a component. The base component of a line should probably be a `space`
component.

```lua
{
  statusline = {
    default = { },
    ["FILETYPE"] = { },
    [{ "FILETYPE", "FILETYPE" }] = { },
  },
  ... -- other lines or components
}
```

## Components

Components are lua modules which define a well-formed `render()` function. They
have no particular requirements beyond that. The `render()` function takes two
arguments. The first is the configuration table that was placed into the
`setup()` table above. This probably looks something like this:

```lua
--- in setup
statusline = {
  default = {
    "component",
    option = "value",
    --- possibly more options here
  }
}
```

The second argument the render function expects is the rendering context. This
will include the buffer, window, and tab that the component should render, as
well as if it should render as active, and how wide it should be.

Component modules are located in `lua/contour/components/` on the runtime path.
You can view a list of all existing components (including user-defined
components) with:

    :lua =require"contour.components".list()

Almost all components use highlighting, so it is worth mentioning that
highlights can be either a string, nil, or false. When they are nil or false,
they will be ignored. When a highlight is an empty string, it will reset the
highlighting via `"%*"` (see `:h statusline`). When a non-empty string, the
string will be used as a highlight group name.

### space

The `space` component intelligently spaces out up to three components over its
entire width. See below for split behavior. This component should probably be
the root component of a line, as it makes it very easy to separate other
components in a visually pleasing manner.

    |                             component 1                               |
    | component 1                                               component 2 |
    | component 1                 component 2                   component 3 |

If you would like a right-aligned component, consider using a `group` with
`trim` set to `"left"`.

### group

The `group` component is used to group multiple components together. You can
decide a maximum width that the component should use. The `trim` option
determines which direction should be trimmed and/or padded. Eg. if `trim` is
`"right"` then items that go over `width` will be truncated on the right, and if
the line is less than `width` it will be padded up to `width` on the right. The
list of items to add to the group should be placed in `items`. Groups do not
request any size of their children. This means a component may prematurely
consume all the remaining space if it is not the last component.

### raw

The `raw` component will evaluate the statusline string that you give it,
convert it to contour's internal format, then use that in the remainder of the
rendering pipeline. This may behave differently to standard statuslines in
certain circumstances, for example when using `%=`, but overall the behavior is
sane. Setting `width` is like making the statusline render in a window of that
size. This component will respect the width that the parent gives it.

If you don't know what this component does or how to use it, see `:h
'statusline'` for a guide on statusline formatting.

### function

The `function` component will pass its arguments to the user-defined function
`f`, and pass its output back to the caller. Usage stub below.

```lua
local function_component = {
  "function",
  --- This function is called every time the line is rendered.
  --- @param opts table This is the table this function is in right here.
  --- @param context Contour.Context The context we are rendering in.
  --- - `buf` is the buffer to render
  --- - `win` is the window to render
  --- - `tab` is the tab to render
  --- - `current` is true if the above are current
  --- - `width` is what the parent thinks this component's width should be
  --- @return (string|fun(): string)[] line
  --- MUST return a list of strings and functions. Strings are used directly,
  --- and all "%" will be escaped. To use statusline escapes, make a function
  --- return them. Functions will protect their returns from escaping.
  f = function(opts, context)
    return {
      "",
      function() return "protected" end,
    } -- ALWAYS return a list, even when you have an error
  end,
}
```

Note if you want to use statusline escapes you SHOULD be using the `raw`
component. That component properly handles the escapes and width calculations.
The option to protect strings from escapes using functions in the `function`
component is intended for non-printing escapes, like click callbacks with
`%@@%X` and highlights with `%##` or `%*`.

### buffer

The `buffer` component displays information about a buffer. All options are
explained in the annotation for `Contour.Buffer`. How this information is
displayed can be changed through the `items` key. This determines the items
shown and in what order they appear in the buffer component. Items are in the
table below.

| name         | shows                                                    |
| ------------ | -------------------------------------------------------- |
| `"filename"` | The name of the file, or `default_name`.                 |
| `"relpath"`  | The relative path to the file.                           |
| `"fullpath"` | The full path to the file.                               |
| `"filetype"` | The value of `:set filetype`.                            |
| `"typeicon"` | The icon for the file type (requires `nvim-web-devicons` |
| `"modified"` | `modified_icon` if the buffer is modified.               |
| `"bufnr"`    | The buffer's number.                                     |

### buflist

The `buflist` component displays multiple buffers at once according to a filter
function. By default it shows a list of all loaded, listed buffers. It has a
`buffer` key in which a buffer configuration can be placed to determine how the
buffers are rendered. It also has highlight groups for normal and current
buffers.

### tab

The `tab` component displays information about the current tab. It uses an
`items` list like the `buffer` component, and has several keys to configure
those items. `buflist` configures how the `buflist` item should be rendered.

| name         | shows                                             |
| ------------ | ------------------------------------------------- |
| `"number"`   | The tab's number.                                 |
| `"buflist"`  | A list of buffers visible in this tab.            |
| `"modified"` | An icon if there are modified buffers in the tab. |

### diagnostics

The `diagnostics` component displays diagnostic information about a buffer using
the built-in nvim diagnostics api. When no diagnostics are posted it's pretty
useless, but it won't show any diagnostics that don't exist, so it won't take up
that much space either. Can be set to show the `total` count or `each` type of
diagnostic. You can also configure icons and highlighting for each diagnostic
type, or `default` which is used for when displaying the total number or 0
diagnostics. Highlights are linked to diagnostic highlights by default, you can
set those yourself to change the highlights as well.
