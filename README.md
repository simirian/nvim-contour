# Nvim Contour

by simirian

NeoVim plugin for easy but statusline, tabline, and winbar configuration, with
an emphasis on user control.<br>

## Features

- [ ] _automagically make lua functions work in any line_
- [ ] click callback functions
- [ ] _group items with nested tables_
- [x] components (classes? constructors? idk what to call these)
- [ ] many built-in components
    - [ ] _tabs (tab numbers)_
    - [x] buffers (buffers list)
    - [ ] _tab buffers (tab numbers with a list of their buffers)_
    - [ ] _buffer (includes name, filetype icon, modified icon)_
    - [ ] _diagnostics_
    - [ ] _vim mode display_
    - [ ] git branch / status
    - [ ] git diff (merge with above?)
    - [ ] last search

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
are referred to by their module name. eg. `lua/contour/components/buffer.lua` is
the `buffer` component, and you can use it with `{ "buffer", ... }`, replacing
`...` with whatever options you desire.

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
