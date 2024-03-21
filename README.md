# Entry Selector

A very simple plugin that allows you to fuzzy find entries from different files
using telescope and write your selection under the cursor.

The entries are basically lines in files. You can have different files and
assign them to different _spaces_. By default, a global space will be loaded.

If you write something in the telescope prompt that has no matches and press
enter, that will be added to the space and also inserted under the cursor. Yo
can also delete entries from the telescope prompt by entering normal mode and
press `d` when the entry you want to remove is selected.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim) and setting a space
```lua
{
    "txemaotero/entry_selector.nvim",
    config = function ()
        require("entry_selector").setup({
            spaces = {
                work = os.getenv("HOME") .. "/spaces/work.txt"
            }
        })
    end,
    dependencies = {
        'nvim-telescope/telescope.nvim',
    }
}
```

## Configuration

Here are the available options with their default values:
```lua
{
    -- Map of space_name = "space/file/path"
    spaces = {},
    -- Path to the global space file
    global_space_path = vim.fn.stdpath('data') .. "/entry_selector/global_space.txt"
    -- If true sort the entries alphabetically
    sort_entries = true,
    -- If true and sort_entries == true, reverse the sorting
    reverse_sort = false,
}
```

> IMPORTANT: The files you specified for the spaces must exist, otherwise an
> error will be triggered.

> NOTE: Be aware that the plugin will modify the contents of the files for the
> spaces so try to limit their use for this.


## Functions and mappings

The following utilities are accessible:
- `require("entry_selector").open_space_file("space_name")`: Opens the file
  associated to the space. If you omit the space name (call the function with no
  arguments) you will open the file for the global space. This can be handy if
  you want to add/remove a bunch of entries or for the initial setup.
- `require("entry_selector").select_line("space_name")`: Opens telescope with
  the entries in the given namespace. Again, no name opens the global space.

You can easily attach these functions to the mapping of choice:
```lua
vim.keymap.set('n', '<leader>e', require("entry_selector").open_space_file)
vim.keymap.set('n', '<leader>E', function() require("entry_selector").open_space_file("work") end)
```

## Telescope window

Once you open the telescope window for a space, you will find all the available
entries in the associated file. The entries are by default sorted
alphabetically. In the window you can:

- Press enter with a selected entry: It will be written at your cursor position.
- Press enter with something written and no matches: This will write your prompt
  at your cursor position and add that new entry to that space file. The next
  time you will have this entry as an option.
- Press `<C-d>` in insert mode with a selected line or `d` in normal mode: This
  will delete the entry from the space.

