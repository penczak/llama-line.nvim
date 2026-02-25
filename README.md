# LlamaLine Neovim Plugin

This repo started as a fork of [Supermaven's Neovim Plugin](https://github.com/supermaven-inc/supermaven-nvim) which they have stopped supporting. 

## Installation

Using a plugin manager, run the .setup({}) function in your Neovim configuration file.

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
require("lazy").setup({
    {
      "penczak/llama-line.nvim",
      config = function()
        require("llamaline.nvim").setup({})
      end,
    },
}, {})
```

### Optional configuration

By default, llamaline.nvim will use the `<Tab>` and `<C-]>` keymaps to accept and clear suggestions. You can change these keymaps by passing a `keymaps` table to the .setup({}) function. Also in this table is `accept_word`, which allows partially accepting a completion, up to the end of the next word. By default this keymap is set to `<C-j>`.

The `ignore_filetypes` table is used to ignore filetypes when using llamaline.nvim. If a filetype is present as a key, and its value is `true`, llamaline.nvim will not display suggestions for that filetype.

`suggestion_color` and `cterm` options can be used to set the color of the suggestion text.

```lua
require("llamaline.nvim").setup({
  keymaps = {
    accept_suggestion = "<Tab>",
    clear_suggestion = "<C-]>",
    accept_word = "<C-j>",
    polite_suggestion = "<C-l>",
  },
  ignore_filetypes = { cpp = true }, -- or { "cpp", }
  color = {
    suggestion_color = "#ffffff",
    cterm = 244,
  },
  log_level = "info", -- set to "off" to disable logging completely
  disable_inline_completion = false, -- disables inline completion for use with cmp
  disable_keymaps = false, -- disables built in keymaps for more manual control
  polite_mode = false, -- disables auto-completions until requested by user. requires keymaps.polite_suggestion to be set
  ollama_model = "codellama:7b-code",
  fim_style = "<PRE>, -- this is the fill-in-middle (FIM) style which can vary depending on which FIM model you use. options currently are "<PRE>" (codellama) or "<|fim_prefix|>" (codegemma)
  condition = function()
    return false
  end -- condition to check for stopping llamaline, `true` means to stop llamaline when the condition is true.
})
```

### Disabling llamaline.nvim conditionally

By default, llamaline.nvim will always run unless `condition` function returns true or
current filetype is in `ignore_filetypes`.

You can disable llamaline.nvim conditionally by setting `condition` function to return true.

```lua
require("llamaline.nvim").setup({
  condition = function()
    return string.match(vim.fn.expand("%:t"), "foo.sh")
  end,
})
```

This will disable llamaline.nvim for files with the name `foo.sh` in it, e.g. `myscriptfoo.sh`.

### Using with nvim-cmp

If you are using nvim-cmp, you can use the `llamaline` source (which is registered by default) by adding the following to your `cmp.setup()` function:

```lua
-- cmp.lua
cmp.setup {
  ...
  sources = {
    { name = "llamaline" },
  }
  ...
}
```

It also has a builtin highlight group CmpItemKindLlamaLine. To add an icon to LlamaLine for lspkind, simply add LlamaLine to your lspkind symbol map.

```lua
-- lspkind.lua
local lspkind = require("lspkind")
lspkind.init({
  symbol_map = {
    LlamaLine = "",
  },
})

vim.api.nvim_set_hl(0, "CmpItemKindLlamaLine", {fg ="#6CC644"})
```

Alternatively, you can add LlamaLine to the lspkind symbol_map within the cmp format function.

```lua
-- cmp.lua
cmp.setup {
  ...
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol",
      max_width = 50,
      symbol_map = { LlamaLine = "" }
    })
  }
  ...
}
```


### Programmatically checking and accepting suggestions

Alternatively, you can also check if there is an active suggestion and accept it programmatically.

For example:

```lua
require("llamaline.nvim").setup({
  disable_keymaps = true
})

...

M.expand = function(fallback)
  local luasnip = require('luasnip')
  local suggestion = require('llamaline.nvim.completion_preview')

  if luasnip.expandable() then
    luasnip.expand()
  elseif suggestion.has_suggestion() then
    suggestion.on_accept_suggestion()
  else
    fallback()
  end
end
```

## Usage

You can also use `:LlamaLineShowLog` to view the logged messages in `path/to/stdpath-cache/llamaline.nvim.log` if you encounter any issues. Or `:LlamaLineClearLog` to clear the log file.

### Commands

llamaline.nvim provides the following commands:

```
:LlamaLineShowLog  show logs for llamaline.nvim
:LlamaLineClearLog clear logs for llamaline.nvim
```

### Lua API

The `llamaline.nvim.api` module provides the following functions for interacting with llamaline.nvim from Lua:

```lua
local api = require("llamaline.nvim.api")

api.show_log() -- show logs for llamaline.nvim
api.clear_log() -- clear logs for llamaline.nvim
```
