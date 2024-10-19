# Nvim Contour

by simirian

NeoVim plugin for easy but statusline, tabline, and winbar configuration, with
an emphasis on user control.

## Features

- [ ] _automagically make lua functions work in any line_
- [ ] click callback functions
- [ ] per-filetype configuration
- [ ] components
    - [x] group (multiple components in one, with truncation)
    - [x] space (spacing and alignment component)
    - [x] buffers (buffers list)
    - [ ] _tabs (tab numbers)_
    - [ ] _tab buffers (tab numbers with a list of their buffers)_
    - [ ] _buffer (includes name, filetype icon, modified icon)_
    - [ ] _diagnostics_
    - [ ] _vim mode display_
    - [ ] git branch / status
    - [ ] git diff (merge with above?)
    - [ ] last search
    - [ ] custom creation api

## Installation

Just use lazy. `"simirian/nvim-contour"`

## Configuration

The main config table can include several values. Any key that is the name of a
component will set that component's default options. Other than that the
`winbar`, `statusline`, and `tabline` keys will all set their respective lines.
The lines are each configured in tables whose keys are the file types for which
they should be set. `"default"` means the line will be set globally.

```lua
{
  COMPONENT = {
    ... -- defaults
  },
  statusline = {
    default = { },
    ["FILETYPE"] = { },
    [{ "FILETYPE", "FILETYPE" }] = { },
  },
  ... -- other lines or components
}
```

## Components

Components are modules which define a set of options, a render function, and a
setup function. The setup function is used to change the component's default
options. The render function is used to determine what the component should
actually look like. Components are all located in `lua/contour/components/` and
are referred to by their module name. Eg. `lua/contour/components/buffer.lua` is
the `buffer` component, and you can use it with `{ "buffer", ... }`, replacing
`...` with whatever options you desire.

If you're unsure about how to configure a component, then just look at the
source code. You can find it wherever your plugin is locally installed. Running
the vim command below should show you where it is located. (explanation given
above command)

         `=` to print output of this lua expression
         |      the value of the 'runtimepath' option
         |      |           the part that matches this regular expression
         v      v           v
    :lua =vim.o.runtimepath:match("[^,]*nvim%-contour")

You can also find the component modules by running the command below, replacing
`COMPONENT` with the component you want to find (or `*` to list them all).

                  list files loaded in the runtime
                  |                      look for the component's lua module
                  v                      v
    :lua =vim.api.nvim_get_runtime_file("lua/contour/components/COMPONENT.lua", true)

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

### diagnostics

The `diagnostics` component displays diagnostic information about a buffer using
the built-in nvim diagnostics api. When no diagnostics are posted it's pretty
useless, but it won't show any diagnostics that don't exist, so it won't take up
that much space either. Can be set to show the `total` count or `each` type of
diagnostic. You can also configure icons and highlighting for each diagnostic
type, or `default` which is used for when displaying the total number or 0
diagnostics. Highlights are linked to diagnostic highlights by default, you can
set those yourself to change the highlights as well.

### group

The `group` component is used to group multiple components together. You can
decide a width that the component should use. The `trim` option determines which
direction should be trimmed and/or padded. Eg. if `trim` is `"right"` then items
that go over `width` will be truncated, and if the line is less than `width` it
will be padded up to `width` on the right. The list of items to add to the group
should be placed in `items`. Groups do not request any size of their children.
This means a component may prematurely consume all the remaining space if it is
not the last component.

### space

The `space` component is meant to be a dynamic spacer for up to three other
components. It will take its width either from what it is given by the parent
element (only reliable as a child of a `space` or as a top-level element) or
from the `width` option. With one child component, that item will be centered
within `width`. With two children, they will be left and right aligned across
`width`, and will each be given half width. With three children, they will be
left, then center, then right aligned, and will each be given one-third width.

Note that while `space` does tell its children how much space they have to
render, it *does not* enforce this width. This makes it much more forgiving and
dynamic when it comes to orienting components. The only time there will be an
actual problem is if the components collide with each other. If you want to
enforce truncation use a `group` component within the `space` component.

If you just want a right aligned component, you can use a `group` with `trim =
"left"` or you can use a space with empty group component children.
