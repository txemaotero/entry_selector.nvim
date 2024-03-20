# Entry Selector

A very simple plugin that allows you to fuzzy find entries from different files
using telescope and write your selection under the cursor.

The entries are basically lines in files. You can have different files and
assign them to different _spaces_. By default, a global space will be loaded.

If you write something in the telescope prompt that has no matches and press
enter, that will be added to the space and also inserted under the cursor. Yo
can also delete entries from the telescope prompt by entering normal mode and
press `d` when the entry you want to remove is selected.

> NOTE: Be aware that the plugin will modify the contents of the files for the
> spaces so try to limit their use for this.

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

> IMPORTANT: The files you specified for the spaces must exist, otherwise an
> error will be triggered.
